#!/bin/bash
# ============LICENSE_START=======================================================
# ONAP : SDN-C
# ================================================================================
# Copyright (C) 2026 Deutsche Telekom AG
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================
#
# Usage: boot-check.sh IMAGE OUTDIR
# Starts IMAGE next to a MariaDB container, waits until the Karaf bundle states
# stop changing, writes what Karaf loaded to OUTDIR and exits 1 if Karaf could not
# install its boot features or a bundle ended up in Failure, GracePeriod or an
# unexpected Waiting state.

set -u

IMAGE=$1
OUT=$2
ALLOW_WAITING=${ALLOW_WAITING:-ansible-adaptor}
TIMEOUT=${TIMEOUT:-900}
NET=sdnc-boot-check-$$
DB=$NET-db
SDNC=$NET-sdnc
ODL=/opt/opendaylight/current
FAILED=0

report() {
    if [ "$2" -eq 0 ]; then echo "PASS $1"; else echo "FAIL $1"; FAILED=1; fi
}

# The client prints only "Closed" when the command is an argument and there is no TTY, so feed it on stdin.
karaf() {
    echo "$1" | docker exec -i "$SDNC" "$ODL/bin/client" -r 3 -d 5 -b 2>/dev/null
}

states() {
    karaf "bundle:list -t 0 --no-format" | awk -F'\t' 'NF>=5 {gsub(/ /,"",$2); print $2}' | sort | uniq -c
}

cleanup() {
    docker rm -f "$SDNC" "$DB" >/dev/null 2>&1
    docker network rm "$NET" >/dev/null 2>&1
}
trap cleanup EXIT

mkdir -p "$OUT"
docker network create "$NET" >/dev/null
docker run -d --name "$DB" --network "$NET" \
    --network-alias dbhost --network-alias sdnctldb01 --network-alias sdnctldb02 \
    -e MARIADB_ROOT_PASSWORD=openECOMP1.0 -e MARIADB_DATABASE=sdnctl \
    -e MARIADB_USER=sdnctl -e MARIADB_PASSWORD=gamma docker.io/library/mariadb:11.4 >/dev/null
docker run -d --name "$SDNC" --network "$NET" \
    -e SDNC_DB_INIT=false -e ODL_ADMIN_USERNAME=admin -e ODL_ADMIN_PASSWORD=admin \
    -e MYSQL_ROOT_PASSWORD=openECOMP1.0 -e MYSQL_DATABASE=sdnctl \
    -e MYSQL_USER=sdnctl -e MYSQL_PASSWORD=gamma -e KARAF_CONSOLE_LOG_LEVEL=info \
    "$IMAGE" >/dev/null

start=$(date +%s)
prev=
stable=0
while [ "$stable" -lt 4 ]; do
    if [ "$(docker inspect -f '{{.State.Running}}' "$SDNC")" != true ]; then
        echo "FAIL container exited during boot"
        docker logs "$SDNC" > "$OUT/container.log" 2>&1
        exit 1
    fi
    if [ $(( $(date +%s) - start )) -ge "$TIMEOUT" ]; then
        report "bundle states settle within ${TIMEOUT}s" 1
        break
    fi
    now=$(states | tr -s ' ' | tr '\n' ';')
    if [ -n "$now" ] && [ "$now" = "$prev" ]; then stable=$((stable + 1)); else stable=0; fi
    prev=$now
    sleep 15
done

docker exec "$SDNC" cat "$ODL/etc/org.apache.karaf.features.cfg" > "$OUT/features.cfg"
docker exec "$SDNC" sh -c "cat $ODL/etc/*.xml" > "$OUT/etc-xml.txt"
karaf "feature:list -i --no-format" | sort > "$OUT/features-installed.txt"
karaf "feature:list --no-format" | sort > "$OUT/features-available.txt"
karaf "feature:repo-list --no-format" | awk -F'\t' '{gsub(/ /,"",$2); print $2}' | sort > "$OUT/repos.txt"
karaf "bundle:list -t 0 --no-format" > "$OUT/bundles.txt"
docker exec "$SDNC" cat "$ODL/data/log/karaf.log" > "$OUT/karaf.log"
docker logs "$SDNC" > "$OUT/container.log" 2>&1
docker exec "$SDNC" sh -c "cd $ODL/system && find . -type f | sort" > "$OUT/system-files.txt"

echo "bundle states: $(states | tr -s ' ' | tr '\n' ' ')"
! grep -q 'Error installing boot feature' "$OUT/karaf.log"
report "Karaf installs its boot features" $?
[ -s "$OUT/repos.txt" ]
report "Karaf lists feature repositories" $?
bad=$(awk -F'\t' 'NF>=5 {s=$2; gsub(/ /,"",s); if (s ~ /^(Failure|GracePeriod|Waiting)$/) print s": "$5}' "$OUT/bundles.txt" \
    | grep -vE "^Waiting: .*($ALLOW_WAITING)" || true)
[ -z "$bad" ]
report "no bundle in Failure, GracePeriod or unexpected Waiting${bad:+ ($bad)}" $?

exit $FAILED
