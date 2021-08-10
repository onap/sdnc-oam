#!/bin/bash
#
#  ============LICENSE_START=======================================================
#  ONAP : ccsdk feature sdnr wt
#  ================================================================================
#  Copyright (C) 2021 highstreet technologies GmbH Intellectual Property.
#  All rights reserved.
#  ================================================================================
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#  ============LICENSE_END=========================================================
#
docker version
docker-compose version
# update installed docker compose version
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
which docker-compose
docker version
docker-compose version

if [[ -z $WORKSPACE ]]; then
    CUR_PATH="`dirname \"$0\"`"              # relative path
    CUR_PATH="`( cd \"$CUR_PATH\" && pwd )`"  # absolutized and normalized
    if [ -z "$CUR_PATH" ] ; then
        echo "Permission error!"
        exit 1
    fi

    # define location of workpsace based on where the current script is
    WORKSPACE=$(cd $CUR_PATH/../../ && pwd)
fi

if [[ -z $SCRIPTS ]]; then
    SCRIPTS=$(cd $WORKSPACE/scripts && pwd)
fi

HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $7}')
SDNC_WEB_PORT=${SDNC_WEB_PORT:-8282}

env_file="--env-file ${SCRIPTS}/sdnr/docker-compose/.env"
echo $env_file

# Define sdnrdb type
# default: ESDB
# alternative: MARIADB
SDNRDB_TYPE="${SDNRDB_TYPE:-ESDB}"
if [[ "$SDNRDB_TYPE" == "ESDB" ]]; then
  sdnrdb_compose_file="docker-compose-sdnrdb-elasticsearch.yaml"
else
  sdnrdb_compose_file="docker-compose-sdnrdb-mariadb.yaml"
fi
docker ps -a

function onap_dependent_components_launch() {
    docker-compose $env_file -f ${WORKSPACE}/scripts/sdnr/docker-compose/docker-compose-onap-addons.yaml pull
    docker-compose $env_file -f ${WORKSPACE}/scripts/sdnr/docker-compose/docker-compose-onap-addons.yaml up -d
}
function netconfserver_simulator_launch() {
    docker-compose $env_file -f ${WORKSPACE}/scripts/sdnr/docker-compose/docker-compose-netconfserver-simulator.yaml pull
    docker-compose $env_file -f ${WORKSPACE}/scripts/sdnr/docker-compose/docker-compose-netconfserver-simulator.yaml up -d
}

function nts_manager_launch() {
    # starts all ntsim managers defined in the csv file
    ${SCRIPTS}/sdnr/docker-compose/nts-manager-launch.sh $1
}

function nts_networkfunctions_launch() {
    # starts all ntsim networkfucntions defined in the csv file
    ${SCRIPTS}/sdnr/docker-compose/nts-networkfunctions-launch.sh $1
}


function sdnr_launch() {
    #if [ -n "${CALLHOME}" ] ; then
      #sdnrwtbootfeatures="-e SDNRWT_BOOTFEATURES=odl-netconf-callhome-ssh,sdnr-wt-feature-aggregator "
      #callhomeport="-p ${CALL_HOME_PORT}:6666 "
    #fi
    if [ $SDNR_CLUSTER_MODE == "true" ]; then
        sdnr_launch_cluster $1
    else
        sdnr_launch_single_node $1
    fi
    cd $WORKSPACE
    ./getAllInfo.sh -c sdnr -kp
}


function sdnr_launch_single_node() {

    # Use locally build sdnr .. no need to pull
    #docker-compose $env_file -f ${WORKSPACE}/scripts/sdnr/docker-compose/docker-compose-single-sdnr.yaml \
    #                         -f ${WORKSPACE}/scripts/sdnr/docker-compose/$sdnrdb_compose_file \
    #                         pull
    docker-compose $env_file -f ${WORKSPACE}/scripts/sdnr/docker-compose/$sdnrdb_compose_file \
                             pull
    docker-compose $env_file -f ${WORKSPACE}/scripts/sdnr/docker-compose/docker-compose-single-sdnr.yaml \
                             -f ${WORKSPACE}/scripts/sdnr/docker-compose/$sdnrdb_compose_file \
                             up -d
         for i in {1..50}; do
             curl -sS -m 1 -D - ${HOST_IP}:8181/ready | grep 200 && break
             echo sleep $i
             sleep $i
             if [ $i == 50 ]; then
                echo "[ERROR] SDNC/R container not ready"
                docker ps -a
                docker logs sdnr
                # exit 1
             fi
         done
}

function sdnr_web_launch() {
    docker-compose $env_file -f ${WORKSPACE}/scripts/sdnr/docker-compose/docker-compose-single-sdnr.yaml \
                             -f ${WORKSPACE}/scripts/sdnr/docker-compose/docker-compose-single-sdnr-web.override.yaml \
                             -f ${WORKSPACE}/scripts/sdnr/docker-compose/$sdnrdb_compose_file \
                             pull
    docker-compose $env_file -f ${WORKSPACE}/scripts/sdnr/docker-compose/docker-compose-single-sdnr.yaml \
                             -f ${WORKSPACE}/scripts/sdnr/docker-compose/docker-compose-single-sdnr-web.override.yaml \
                             -f ${WORKSPACE}/scripts/sdnr/docker-compose/$sdnrdb_compose_file \
                             up -d
         for i in {1..50}; do
             curl -sS -m 1 -D - ${HOST_IP}:${SDNC_WEB_PORT}/ready | grep 200 && break
             echo sleep $i
             sleep $i
    done
}

function sdnr_launch_cluster() {
    # source ${SCRIPTS}/sdnr/sdnrEnv_Cluster.sh
    SDNRDM="false"
    [[ -n "$1" ]]  && SDNRDM="true" && echo "SDNRDM arg detected - running in headless mode"
    echo "SDNR being launched in Cluster mode"
    docker-compose $env_file -f ${WORKSPACE}/scripts/sdnr/docker-compose/docker-compose/cluster-sdnr.yaml pull
    docker-compose $env_file -f ${WORKSPACE}/scripts/sdnr/docker-compose/docker-compose/cluster-sdnr.yaml up -d
    # Wait for initialization of docker services. At the moment its the master SDNR node
         HOST_IP=$(ip route get 8.8.8.8 | awk '/8.8.8.8/ {print $7}')
         for i in {1..50}; do
             curl -sS -m 1 -D - ${HOST_IP}:${ODLUXPORT}/ready | grep 200 && break
             echo sleep $i
             sleep $i
         done
}
