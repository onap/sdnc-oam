#!/bin/bash
# SPDX-License-Identifier: Apache-2.0
# Copyright 2024 ONAP Contributors
#
# Script to download OpenAPI/Swagger specifications from remote repositories
# for use with sphinxcontrib-openapi documentation generation.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Generic Resource API spec from sdnc/northbound repository
# Using master branch for latest version
GENERIC_RESOURCE_API_URL="https://gerrit.onap.org/r/gitweb?p=sdnc/northbound.git;a=blob_plain;f=generic-resource-api/model/swagger/src/main/json/generic-resource.json;hb=refs/heads/master"
GENERIC_RESOURCE_API_FILE="${SCRIPT_DIR}/generic-resource-api.json"

echo "Downloading OpenAPI specifications..."

# Download Generic Resource API spec
echo "  - Downloading Generic Resource API spec..."
if curl -sSfL -o "${GENERIC_RESOURCE_API_FILE}" "${GENERIC_RESOURCE_API_URL}"; then
    echo "    Successfully downloaded: ${GENERIC_RESOURCE_API_FILE}"
else
    echo "    WARNING: Failed to download Generic Resource API spec"
    echo "    Creating placeholder file..."
    cat > "${GENERIC_RESOURCE_API_FILE}" << 'EOF'
{
  "swagger": "2.0",
  "info": {
    "title": "Generic Resource API",
    "description": "API specification temporarily unavailable. Please refer to the sdnc/northbound repository for the latest specification.",
    "version": "1.0.0"
  },
  "paths": {}
}
EOF
fi

echo "Done."