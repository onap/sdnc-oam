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
# Usage: image-tree-diff.sh OLD_IMAGE NEW_IMAGE [ROOT...]
# Diffs "mode owner:group path" for every file under ROOT in both images.
# Version numbers in paths are normalised to <v>, so a newer SNAPSHOT of the
# same artifact does not show up as a difference.

set -euo pipefail

OLD=$1
NEW=$2
shift 2
ROOTS=${*:-/opt/opendaylight /opt/onap /opt/opentelemetry}

listing() {
    docker run --rm -u 0 --entrypoint sh "$1" -c "find $ROOTS -exec stat -c '%a %U:%G %n' {} +" \
        | sed -E 's#([/-])[0-9]+\.[0-9]+\.[0-9]+(-SNAPSHOT|-[0-9]{8}\.[0-9]{6}-[0-9]+)?#\1<v>#g' \
        | sort -u
}

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
listing "$OLD" > "$TMP/old" || { echo "cannot list $OLD" >&2; exit 2; }
listing "$NEW" > "$TMP/new" || { echo "cannot list $NEW" >&2; exit 2; }
diff -u "$TMP/old" "$TMP/new"
