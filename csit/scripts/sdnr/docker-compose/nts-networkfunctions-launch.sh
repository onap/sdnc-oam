#!/bin/bash
# *******************************************************************************
# * ============LICENSE_START========================================================================
# * Copyright (C) 2021 highstreet technologies GmbH Intellectual Property. All rights reserved.
# * =================================================================================================
# * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
# * in compliance with the License. You may obtain a copy of the License at
# *
# * http://www.apache.org/licenses/LICENSE-2.0
# *
# * Unless required by applicable law or agreed to in writing, software distributed under the License
# * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
# * or implied. See the License for the specific language governing permissions and limitations under
# * the License.
# * ============LICENSE_END==========================================================================

set -o xtrace
set +e
csvfile=$1
export DOCKER_ENGINE_VERSION=$(docker version --format '{{.Server.APIVersion}}')

CUR_PATH="`dirname \"$0\"`"              # relative path
CUR_PATH="`( cd \"$CUR_PATH\" && pwd )`"  # absolutized and normalized
if [ -z "$CUR_PATH" ] ; then
    echo "Permission error!"
    exit 1
fi

# define location of workpsace based on where the current script is
WORKSPACE=$(cd $CUR_PATH/../../../ && pwd)
if [ $# -lt 1 ]; then
    echo "No arguments provided. Using default 'nts-networkfunctions.csv'"
    csvfile="$CUR_PATH/nts-networkfunctions.csv"
fi

firstline=0
# read each line of nts-networkfunctions.csv and put in into the corresponding variables
while IFS=',' read NAME NTS_NF_DOCKER_REPOSITORY NTS_NF_IMAGE_NAME NTS_NF_IMAGE_TAG NTS_NF_IP NTS_NF_IPv6 \
                   NTS_HOST_NETCONF_SSH_BASE_PORT NTS_HOST_NETCONF_TLS_BASE_PORT NTS_NF_SSH_CONNECTIONS NTS_NF_TLS_CONNECTIONS \
                   PORT NETCONF_HOST USER PASSWORD NTS_FUNCTION_TYPE; do
    if [ $firstline -eq 0 ]; then
        firstline=1
        continue
    fi
    if [ -n "${NTS_NF_GLOBAL_TAG}" ]; then
      NTS_NF_IMAGE_TAG=${NTS_NF_GLOBAL_TAG}
    fi
        if [[ -z ${USE_DEFAULT_REPO} ]]; then
        export NTS_NF_DOCKER_REPOSITORY=$NTS_NF_DOCKER_REPOSITORY
    fi
    export NAME=$NAME
    export NTS_NF_IMAGE_NAME=$NTS_NF_IMAGE_NAME
    export NTS_NF_IMAGE_TAG=$NTS_NF_IMAGE_TAG
    export NTS_NF_IP=$NTS_NF_IP
    export NTS_NF_IPv6=$NTS_NF_IPv6
    export NTS_HOST_NETCONF_SSH_BASE_PORT=$NTS_HOST_NETCONF_SSH_BASE_PORT
    export NTS_HOST_NETCONF_TLS_BASE_PORT=$NTS_HOST_NETCONF_TLS_BASE_PORT
    export NTS_HOST_NETCONF_SSH_BASE_PORT_PLUS_SSH_CON=$(expr $NTS_HOST_NETCONF_SSH_BASE_PORT + $NTS_NF_SSH_CONNECTIONS - 1)
    export NTS_HOST_NETCONF_TLS_BASE_PORT_PLUS_TLS_CON=$(expr $NTS_HOST_NETCONF_TLS_BASE_PORT + $NTS_NF_TLS_CONNECTIONS - 1)
    EXPOSE_PORT=830
    export EXPOSE_PORT_SSH=$EXPOSE_PORT
    EXPOSE_PORT=$(expr $EXPOSE_PORT + $NTS_NF_SSH_CONNECTIONS)
    export EXPOSE_PORT_SSH_PLUS_CON=$(expr $EXPOSE_PORT - 1)
    export EXPOSE_PORT_TLS=$EXPOSE_PORT
    EXPOSE_PORT=$(expr $EXPOSE_PORT + $NTS_NF_TLS_CONNECTIONS)
    export EXPOSE_PORT_TLS_PLUS_CON=$(expr $EXPOSE_PORT - 1)
    export NTS_NF_CONTAINER_NAME=$NAME
    export NTS_NF_SSH_CONNECTIONS=$NTS_NF_SSH_CONNECTIONS
    export NTS_NF_TLS_CONNECTIONS=$NTS_NF_TLS_CONNECTIONS

    SCRIPTDIR=${CUR_PATH}/$NAME/scripts
    export SCRIPTDIR=$SCRIPTDIR

    mkdir -p $SCRIPTDIR

    docker-compose -p ${NAME} --env-file $CUR_PATH/.env -f $CUR_PATH/docker-compose-nts-networkfunction.yaml up -d
done <$csvfile
docker ps -a --format "table |{{.Names}}\t|{{.Image}}\t|{{printf \"%.70s\" .Ports}}|"| { head -1; sort --field-separator='|' -k 4;}
set -e
