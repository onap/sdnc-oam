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
# Usage: distribution-check.sh TARBALL SLI_VERSION FEATURES_VERSION A1_VERSION NORTHBOUND_VERSION [ONAP_KARAF_TARBALL]
# Checks a Karaf distribution tarball without Docker. With ONAP_KARAF_TARBALL it
# also checks that the ODL part is the same as in ODL's onap-karaf and that no
# feature bundle is missing that onap-karaf has.

set -u

TAR=$1; SLI=$2; FEAT=$3; A1=$4; NB=$5; REF=${6:-}
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
FAILED=0

report() {
    if [ "$2" -eq 0 ]; then echo "PASS $1"; else echo "FAIL $1"; FAILED=1; fi
}

unpack() {
    mkdir -p "$WORK/$2" && tar xzf "$1" -C "$WORK/$2" && echo "$WORK/$2"/*
}

repos() {
    cat "$1"/etc/*.xml | grep -o '<repository>[^<]*' | cut -c13- | sort -u
}

# Prints every mvn: bundle URL referenced by a feature in $1/system that has no file there.
missing_bundles() {
    find "$1/system" -name '*-features.xml' -print0 \
        | xargs -0 grep -ohE '<bundle[^>]*>[^<]+' \
        | sed -E 's/^<bundle[^>]*>//; s/^wrap://; s/\$.*$//' | grep '^mvn:' | sort -u \
        | while IFS= read -r url; do
            IFS=/ read -r g a v t c <<<"${url#mvn:}"
            f="$a-$v${c:+-$c}.${t:-jar}"
            [ -f "$1/system/${g//.//}/$a/$v/$f" ] || echo "$url"
        done
}

H=$(unpack "$TAR" new)

for f in bin/karaf bin/client bin/configure_cluster.sh bin/set_persistence.sh bin/aaa-cli-jar.jar \
        etc/org.apache.karaf.features.cfg etc/odl.java.security; do
    [ -e "$H/$f" ]
    report "has $f" $?
done
for jar in sdnr-wt-data-provider-setup; do
    [ -n "$(find "$H/system" -name "$jar-*.jar" | head -1)" ]
    report "system/ has $jar (used by startODL.sh)" $?
done
grep -qx 'org.ops4j.pax.url.mvn.repositories=' "$H/etc/org.ops4j.pax.url.mvn.cfg"
report "resolves bundles from system/ only" $?

repos "$H" > "$WORK/repos"
! grep -q '\[' "$WORK/repos"
report "feature repositories pin exact versions" $?
while read -r gav; do
    grep -qx "mvn:$gav/xml/features" "$WORK/repos"
    report "registers $gav" $?
    IFS=/ read -r g a v <<<"$gav"
    [ -f "$H/system/${g//.//}/$a/$v/$a-$v-features.xml" ]
    report "system/ has the $a $v feature descriptor" $?
done <<EOF2
org.onap.ccsdk.sli.core/ccsdk-sli-core-all/$SLI
org.onap.ccsdk.sli.adaptors/ccsdk-sli-adaptors-all/$SLI
org.onap.ccsdk.sli.northbound/ccsdk-sli-northbound-all/$SLI
org.onap.ccsdk.sli.plugins/ccsdk-sli-plugins-all/$SLI
org.onap.ccsdk.features.sdnr.northbound/sdnr-northbound-all/$FEAT
org.onap.ccsdk.features.sdnr.wt/sdnr-wt-feature-aggregator/$FEAT
org.onap.ccsdk.features.sdnr.wt/sdnr-wt-feature-aggregator-devicemanager/$FEAT
org.onap.ccsdk.features.sdnr.wt/sdnr-wt-feature-aggregator-devicemanager-base/$FEAT
org.onap.ccsdk.features.sdnr.wt/sdnr-wt-feature-aggregator-oauth/$FEAT
org.onap.ccsdk.oran/a1-adapter-northbound/$A1
org.onap.sdnc.northbound/sdnc-northbound-all/$NB
EOF2
! grep -q 'odl-legacy' "$WORK/repos"
report "does not register the odl-legacy repositories" $?

missing_bundles "$H" > "$WORK/missing"
if [ -n "$REF" ]; then
    R=$(unpack "$REF" ref)
    repos "$R" > "$WORK/ref-repos"
    comm -23 "$WORK/ref-repos" "$WORK/repos" > "$WORK/odl-diff"
    [ ! -s "$WORK/odl-diff" ]
    rc=$?
    report "registers every onap-karaf repository at the same version$( [ -s "$WORK/odl-diff" ] && echo " (missing: $(tr '\n' ' ' < "$WORK/odl-diff"))")" $rc
    missing_bundles "$R" > "$WORK/ref-missing"
    comm -23 "$WORK/missing" "$WORK/ref-missing" > "$WORK/new-missing"
    mv "$WORK/new-missing" "$WORK/missing"
fi
[ ! -s "$WORK/missing" ]
rc=$?
report "every feature bundle is in system/ ($(wc -l < "$WORK/missing") missing)" $rc
head -20 "$WORK/missing"

exit $FAILED
