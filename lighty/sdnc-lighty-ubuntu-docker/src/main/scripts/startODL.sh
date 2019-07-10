#!/bin/bash

###
# ============LICENSE_START=======================================================
# openECOMP : SDN-C
# ================================================================================
# Copyright (C) 2017 AT&T Intellectual Property. All rights
#                             reserved.
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
# ============LICENSE_END=========================================================
###


# Install SDN-C platform components if not already installed and start container

ODL_HOME=${ODL_HOME:-/opt/opendaylight/current}
ODL_ADMIN_USERNAME=${ODL_ADMIN_USERNAME:-admin}
ODL_ADMIN_PASSWORD=${ODL_ADMIN_PASSWORD:-Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U}
SDNC_HOME=${SDNC_HOME:-/opt/onap/sdnc}
SDNC_BIN=${SDNC_BIN:-/opt/onap/sdnc/bin}
CCSDK_HOME=${CCSDK_HOME:-/opt/onap/ccsdk}
SLEEP_TIME=${SLEEP_TIME:-120}
MYSQL_PASSWD=${MYSQL_PASSWD:-openECOMP1.0}
ENABLE_ODL_CLUSTER=${ENABLE_ODL_CLUSTER:-false}
IS_PRIMARY_CLUSTER=${IS_PRIMARY_CLUSTER:-false}
MY_ODL_CLUSTER=${MY_ODL_CLUSTER:-127.0.0.1}
INSTALLED_DIR=${INSTALLED_FILE:-/opt/opendaylight/current/daexim}
SDNRWT=${SDNRWT:-false}
SDNRWT_BOOTFEATURES=${SDNRWT_BOOTFEATURES:-sdnr-wt-feature-aggregator}
SDNR_NORTHBOUND=${SDNR_NORTHBOUND:-false}
SDNR_NORTHBOUND_BOOTFEATURES=${SDNR_NORTHBOUND_BOOTFEATURES:-sdnr-northbound-all}
export ODL_ADMIN_PASSWORD ODL_ADMIN_USERNAME

echo "Settings:"
echo "  ENABLE_ODL_CLUSTER=$ENABLE_ODL_CLUSTER"
echo "  SDNC_REPLICAS=$SDNC_REPLICAS"
echo "  SDNRWT=$SDNRWT"
echo "  SDNR_NORTHBOUND=$SDNR_NORTHBOUND"

#
# Wait for database
#
echo "Waiting for mysql"
until mysql -h dbhost -u root -p${MYSQL_PASSWD} mysql &> /dev/null
do
  printf "."
  sleep 1
done
echo -e "\nmysql ready"

echo "Installing SDN-C database"
${SDNC_HOME}/bin/installSdncDb.sh

echo "Installing SDN-C keyStore"
${SDNC_HOME}/bin/addSdncKeyStore.sh

if [ -x ${SDNC_HOME}/svclogic/bin/install.sh ]
then
    echo "Installing directed graphs"
    ${SDNC_HOME}/svclogic/bin/install.sh
fi

cp /opt/opendaylight/current/certs/* /tmp

nohup python ${SDNC_BIN}/installCerts.py &

exec java -jar opt/lighty/sdnc-lighty-application-1.6.0-SNAPSHOT/sdnc-lighty-application-1.6.0-SNAPSHOT.jar /opt/onap/sdnc/data/properties/lightySdncConfig.json
