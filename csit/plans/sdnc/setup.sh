#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Modifications copyright (c) 2020-2021 Samsung Electronics Co., Ltd.
# Modifications copyright (c) 2021 AT&T Intellectual Property
#

# Remove all dangling images and cleanup /w/workspace and /tmp
docker image prune -f
echo "Remove onap repository artifacts"
rm -r /tmp/r/org/onap
echo "Remove all target folders from workspace"
rm -r $(find /w/workspace -name target)

###################### Netconf Simulator Setup ######################

echo "Clean"
sudo apt clean

# Get integration/simulators
if [ -d ${WORKSPACE}/archives/pnf-simulator ]
then
    rm -rf ${WORKSPACE}/archives/pnf-simulator
fi
mkdir ${WORKSPACE}/archives/pnf-simulator
git clone "https://gerrit.onap.org/r/integration/simulators/pnf-simulator" ${WORKSPACE}/archives/pnf-simulator

# Fix docker-compose to add nexus repo for onap dockers
PNF_SIM_REGISTRY=nexus3.onap.org:10001
PNF_SIM_VERSION=1.0.5
mv ${WORKSPACE}/archives/pnf-simulator/netconfsimulator/docker-compose.yml ${WORKSPACE}/archives/pnf-simulator/netconfsimulator/docker-compose.yml.orig
cat ${WORKSPACE}/archives/pnf-simulator/netconfsimulator/docker-compose.yml.orig | sed -re "s/image: onap\/org.onap.integration.simulators.(.*$)/image: $PNF_SIM_REGISTRY\/onap\/org.onap.integration.simulators.\1:$PNF_SIM_VERSION/"  > ${WORKSPACE}/archives/pnf-simulator/netconfsimulator/docker-compose.yml

# Remove carriage returns (if any) from netopeer start script
mv ${WORKSPACE}/archives/pnf-simulator/netconfsimulator/netconf/initialize_netopeer.sh ${WORKSPACE}/archives/pnf-simulator/netconfsimulator/netconf/initialize_netopeer.sh.orig
cat ${WORKSPACE}/archives/pnf-simulator/netconfsimulator/netconf/initialize_netopeer.sh.orig | sed -e "s/\r$//g" > ${WORKSPACE}/archives/pnf-simulator/netconfsimulator/netconf/initialize_netopeer.sh
chmod 755 ${WORKSPACE}/archives/pnf-simulator/netconfsimulator/netconf/initialize_netopeer.sh

# generate fresh certificates for netconfserver [INT-2269]

./generate_certs.sh "${WORKSPACE}"/archives/pnf-simulator/netconfsimulator/tls

# Start Netconf Simulator Container with docker-compose and configuration from docker-compose.yml
docker-compose -f "${WORKSPACE}"/archives/pnf-simulator/netconfsimulator/docker-compose.yml up -d

# Add test user in netopeer container
sleep 60
docker exec netconfsimulator_netopeer_1 useradd --system test

############################## SDNC Setup ##############################

# Copy client certs from netconf simulator to SDNC certs directory
mkdir /tmp/keys0
cp ${WORKSPACE}/archives/pnf-simulator/netconfsimulator/tls/client.crt /tmp/keys0
cp ${WORKSPACE}/archives/pnf-simulator/netconfsimulator/tls/client.key /tmp/keys0
cp ${WORKSPACE}/archives/pnf-simulator/netconfsimulator/tls/ca.crt /tmp/keys0/trustedCertificates.crt
cwd=$(pwd)
cd /tmp
if [ ! -d ${SDNC_CERT_PATH} ]
then
    mkdir -p ${SDNC_CERT_PATH}
fi
chmod -f go+w $SDNC_CERT_PATH
cat > $SDNC_CERT_PATH/certs.properties <<-END
keys0.zip
*****
END
zip -r $SDNC_CERT_PATH/keys0.zip keys0
rm -rf /tmp/keys0


# Export default Networking bridge created on the host machine
export LOCAL_IP=$(ip -4 addr show docker0 | grep -Po 'inet \K[\d.]+')

unset http_proxy https_proxy

# Append test data to standard data init file to create db init script
cat ${WORKSPACE}/../installation/sdnc/src/main/resources/sdnctl.dump ${WORKSPACE}/scripts/csit-data.sql > ${WORKSPACE}/archives/csit-dbinit.sql

# start SDNC containers with docker compose and configuration from docker-compose.yml
docker-compose -f ${SCRIPTS}/docker-compose.yml up -d


# WAIT 5 minutes maximum and check karaf.log for readiness every 10 seconds

TIME_OUT=300
INTERVAL=10
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do

docker exec ${SDNC_CONTAINER_NAME} cat /opt/opendaylight/data/log/karaf.log | grep 'warp coils'

  if [ $? == 0 ] ; then
    echo SDNC karaf started in $TIME seconds
    break;
  fi

  echo Sleep $INTERVAL seconds before testing if SDNC is up. Total wait time up until now is $TIME seconds. Timeout is $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: karaf session not started in $TIME_OUT seconds, setup failed
   exit 1;
fi

num_bundles=$(docker exec -i ${SDNC_CONTAINER_NAME} sh -c "echo '' | /opt/opendaylight/current/bin/client bundle:list" | tail -1 | cut -d' ' -f1)

  if [ "$num_bundles" -ge 333 ]; then
    num_failed_bundles=$(docker exec -i ${SDNC_CONTAINER_NAME} sh -c "echo '' | /opt/opendaylight/current/bin/client bundle:list" | grep -w Failure | wc -l)
    failed_bundles=$(docker exec -i ${SDNC_CONTAINER_NAME} sh -c "echo '' | /opt/opendaylight/current/bin/client bundle:list" | grep -w Failure)
    echo There is/are $num_failed_bundles failed bundles out of $num_bundles installed bundles.
  fi

if [ "$num_failed_bundles" -ge 1 ]; then
  echo "The following bundle(s) are in a failed state: "
  echo "  $failed_bundles"
fi

# Check if certificate installation is done
TIME_OUT=300
INTERVAL=10
TIME=0
while [ "$TIME" -lt "$TIME_OUT" ]; do

  docker-compose -f "${SCRIPTS}"/docker-compose.yml logs sdnc | grep 'Everything OK in Certificate Installation'

  if [ $? == 0 ] ; then
    echo SDNC karaf started in $TIME seconds
    break;
  fi

  echo Sleep: $INTERVAL seconds before testing if SDNC is up. Total wait time up now is: $TIME seconds. Timeout is: $TIME_OUT seconds
  sleep $INTERVAL
  TIME=$(($TIME+$INTERVAL))
done

if [ "$TIME" -ge "$TIME_OUT" ]; then
   echo TIME OUT: karaf session not started in $TIME_OUT seconds, setup failed
   exit 1;
fi

# Update default Networking bridge IP in mount.json file
cp ${REQUEST_DATA_PATH}/mount.xml.tmpl ${REQUEST_DATA_PATH}/mount.xml
sed -i "s/pnfaddr/${LOCAL_IP}/g" "${REQUEST_DATA_PATH}"/mount.xml


#########################################################################

# Export SDNC, AAF-Certservice-Cient, Netconf-Pnp-Simulator Continer Names
export REQUEST_DATA_PATH="${REQUEST_DATA_PATH}"
export SDNC_CONTAINER_NAME="${SDNC_CONTAINER_NAME}"
export CLIENT_CONTAINER_NAME="${CLIENT_CONTAINER_NAME}"
export NETCONF_PNP_SIM_CONTAINER_NAME="${NETCONF_PNP_SIM_CONTAINER_NAME}"

REPO_IP='127.0.0.1'
ROBOT_VARIABLES+=" -v REPO_IP:${REPO_IP} "
ROBOT_VARIABLES+=" -v SCRIPTS:${SCRIPTS} "

echo "Finished executing setup for SDNC"

