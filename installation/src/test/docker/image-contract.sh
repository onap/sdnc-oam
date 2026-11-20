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
# Usage: image-contract.sh sdnc|ueb-listener|dmaap-listener IMAGE [SLI_VERSION]
# Prints one PASS/FAIL line per check and exits 1 if any check failed.

set -u

PROFILE=$1
IMAGE=$2
SLI_VERSION=${3:-}
JAVA_BASE=${JAVA_BASE:-docker.io/library/eclipse-temurin:21-jre-alpine}
SYS=/opt/opendaylight/system
FAILED=0

report() {
    if [ "$2" -eq 0 ]; then echo "PASS $1"; else echo "FAIL $1"; FAILED=1; fi
}

in_image() {
    docker run --rm -u 0 --entrypoint sh "$IMAGE" -c "$1"
}

check() {
    in_image "$2" >/dev/null 2>&1
    report "$1" $?
}

config() {
    docker image inspect "$IMAGE" --format "$1"
}

# Shell snippet run in the image against the jars in "$@": fails when there is
# no jar, a jar cannot be listed, or a jar contains JndiLookup.
NO_JNDI='n=0; for j in "$@"; do [ -f "$j" ] || exit 1; l=$(unzip -l "$j") || exit 1; case $l in *JndiLookup*) exit 1;; esac; n=$((n+1)); done; [ $n -gt 0 ]'

docker pull -q "$JAVA_BASE" >/dev/null
LAYERS='{{range .RootFS.Layers}}{{println .}}{{end}}'
base_layers=$(docker image inspect "$JAVA_BASE" --format "$LAYERS")
[ -n "$base_layers" ] && [ "$(config "$LAYERS" | head -n "$(echo "$base_layers" | wc -l)")" = "$base_layers" ]
report "keeps the layers of $JAVA_BASE" $?

for tool in node npm git sudo dot pip3; do
    check "does not ship $tool" "! command -v $tool"
done

case "$PROFILE" in
sdnc)
    [ "$(config '{{.Config.User}}')" = odl ]
    report "runs as odl" $?
    config '{{json .Config.Entrypoint}}' | grep -q /opt/onap/sdnc/bin/startODL.sh
    report "starts startODL.sh" $?
    check "odl is uid 100 gid 102" '[ "$(id -u odl):$(id -g odl)" = 100:102 ]'
    for tool in bash mariadb mysql python3 curl jq unzip zip openssl keytool java hostname; do
        check "provides $tool" "command -v $tool"
    done
    check "runs Java 21" 'java -version 2>&1 | grep -q "version \"21\."'
    for path in /opt/opendaylight/current/bin/karaf /opt/onap/sdnc/bin/startODL.sh \
            /opt/onap/sdnc/svclogic/graphs /opt/onap/sdnc/bin/installSdncDb.sh \
            /opt/onap/ccsdk/data/properties/a1-adapter-api-dg.properties \
            /opt/onap/ccsdk/data/stores/truststore.onap.client.jks \
            /opt/onap/ccsdk/restapi/templates /opt/opentelemetry/opentelemetry-javaagent.jar /opt/sdnc; do
        check "has $path" "[ -e $path ]"
    done
    check "ODL files owned by odl" '[ "$(stat -c %U /opt/opendaylight/etc/org.apache.karaf.features.cfg)" = odl ]'
    check "SDNC data owned by odl" '[ "$(stat -c %U /opt/onap/sdnc/data/properties)" = odl ]'
    check "no leftover /tmp/system" '[ ! -e /tmp/system ]'
    check "JDK trusts the ONAP test CA" 'keytool -list -cacerts -storepass changeit | grep -q onaptestca'
    check "pax-logging-log4j2 has no JndiLookup" \
        "set -- \$(find $SYS/org/ops4j/pax/logging/pax-logging-log4j2 -name 'pax-logging-log4j2*.jar'); $NO_JNDI"

    features=/opt/opendaylight/etc/org.apache.karaf.features.cfg
    for feature in ccsdk-sli-core-all ccsdk-sli-adaptors-all ccsdk-sli-northbound-all ccsdk-sli-plugins-all \
            sdnc-northbound-all odl-netconf-topology odl-restconf-nb-rfc8040; do
        check "boots $feature" "grep '^featuresBoot' $features | grep -q -- $feature"
    done
    check "feature repositories pin exact versions" \
        "! { sed -n '/^featuresRepositories/,/^\$/p' $features; cat /opt/opendaylight/etc/*.xml; } | grep -q 'mvn:[^<]*\['"
    if [ -n "$SLI_VERSION" ]; then
        check "loads SLI $SLI_VERSION" \
            "cat $features /opt/opendaylight/etc/*.xml | grep -q 'ccsdk-sli-core-all/$SLI_VERSION/xml/features'"
    fi

    while read -r patched sibling central; do
        version=$(in_image "ls $SYS/$sibling" | grep -v maven-metadata)
        found=$(in_image "ls $SYS/$patched" | grep -v maven-metadata | tr '\n' ' ')
        [ "$found" = "$version " ]
        report "$patched has only version $version (found: $found)" $?
        name=$(basename "$patched")
        expected=$(curl -fsS "https://repo1.maven.org/maven2/$central/$version/$name-$version.jar.sha1" | cut -c1-40)
        actual=$(in_image "sha1sum $SYS/$patched/$version/$name-$version.jar" | cut -c1-40)
        [ -n "$expected" ] && [ "$expected" = "$actual" ]
        report "$patched $version is the Highstreet patch" $?
    done <<'EOF'
org/opendaylight/aaa/aaa-authn-api org/opendaylight/aaa/aaa-shiro com/highstreet-technologies/aaa/aaa-authn-api
org/ops4j/pax/web/pax-web-jetty org/ops4j/pax/web/pax-web-api com/highstreet-technologies/org/ops4j/pax/web/pax-web-jetty
EOF
    ;;
ueb-listener|dmaap-listener)
    [ "$(config '{{.Config.User}}')" = sdnc ]
    report "runs as sdnc" $?
    if [ "$PROFILE" = ueb-listener ]; then
        config '{{range .Config.Env}}{{println .}}{{end}}' | grep -qx 'JAVA_OPTS=-XX:MaxRAMPercentage=75.0'
        report "sizes the heap from the container memory limit" $?
        check "has /opt/opentelemetry/opentelemetry-javaagent.jar" '[ -f /opt/opentelemetry/opentelemetry-javaagent.jar ]'
        check "start script attaches the OpenTelemetry agent" \
            "JAVA=echo /opt/onap/sdnc/ueb-listener/bin/start-ueb-listener.sh | grep -q -- '-javaagent:/opt/opentelemetry/opentelemetry-javaagent.jar '"
    else
        config '{{range .Config.Env}}{{println .}}{{end}}' | grep -qx 'JAVA_OPTS=-Xms256m -Xmx1g'
        report "keeps JAVA_OPTS heap defaults" $?
    fi
    check "sdnc is uid 100 gid 102" '[ "$(id -u sdnc):$(id -g sdnc)" = 100:102 ]'
    for tool in bash java; do
        check "provides $tool" "command -v $tool"
    done
    for tool in mariadb python3; do
        check "does not ship $tool" "! command -v $tool"
    done
    check "has start script" "[ -x /opt/onap/sdnc/$PROFILE/bin/start-$PROFILE.sh ]"
    check "files owned by sdnc" "[ \"\$(stat -c %U /opt/onap/sdnc/$PROFILE)\" = sdnc ]"
    check "log4j-core has no JndiLookup" \
        "set -- /opt/onap/sdnc/$PROFILE/lib/log4j-core-*.jar; $NO_JNDI"
    ;;
*)
    echo "unknown profile $PROFILE" >&2
    exit 2
    ;;
esac

exit $FAILED
