#!/bin/bash

###
# ============LICENSE_START=======================================================
# openECOMP : SDN-C
# ================================================================================
# Copyright (C) 2017 AT&T Intellectual Property. All rights
# 							reserved.
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

function enable_odl_cluster(){
  if [ -z $SDNC_REPLICAS]; then
     echo "SDNC_REPLICAS is not configured in Env field"
     exit
  fi

  echo "Installing Opendaylight cluster features"
  ${ODL_HOME}/bin/client -u karaf feature:install odl-mdsal-clustering
  ${ODL_HOME}/bin/client -u karaf feature:install odl-jolokia

  echo "Update cluster information statically"
  hm=$(hostname)
  echo "Get current Hostname ${hm}"

  node=($(echo ${hm} | tr '-' '\n'))
  node_name=${node[0]}
  node_index=${node[1]}
  node_list="${node_name}-0.sdnhostcluster.onap-sdnc.svc.cluster.local";

  for ((i=1;i<=${SDNC_REPLICAS};i++));
  do
    node_list="${node_list} ${node_name}-$i.sdnhostcluster.onap-sdnc.svc.cluster.local"
  done

  /opt/opendaylight/current/bin/configure_cluster.sh $((node_index+1)) ${node_list}
}


# Install SDN-C platform components if not already installed and start container

ODL_HOME=${ODL_HOME:-/opt/opendaylight/current}
ODL_ADMIN_PASSWORD=${ODL_ADMIN_PASSWORD:-Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U}
SDNC_HOME=${SDNC_HOME:-/opt/onap/sdnc}
SLEEP_TIME=${SLEEP_TIME:-120}
MYSQL_PASSWD=${MYSQL_PASSWD:-openECOMP1.0}
ENABLE_ODL_CLUSTER=${ENABLE_ODL_CLUSTER:-false}

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

if [ ! -f ${SDNC_HOME}/.installed ]
then
	echo "Installing SDN-C database"
	${SDNC_HOME}/bin/installSdncDb.sh
	echo "Installing SDN-C keyStore"
	${SDNC_HOME}/bin/addSdncKeyStore.sh
	echo "Starting OpenDaylight"
	${ODL_HOME}/bin/start
	echo "Waiting ${SLEEP_TIME} seconds for OpenDaylight to initialize"
	sleep ${SLEEP_TIME}
	echo "Installing SDN-C platform features"
	${SDNC_HOME}/bin/installFeatures.sh
	if [ -x ${SDNC_HOME}/svclogic/bin/install.sh ]
	then
		echo "Installing directed graphs"
		${SDNC_HOME}/svclogic/bin/install.sh
	fi

        if $ENABLE_ODL_CLUSTER ; then enable_odl_cluster ; fi

	echo "Restarting OpenDaylight"
	${ODL_HOME}/bin/stop
	echo "Installed at `date`" > ${SDNC_HOME}/.installed
fi

exec ${ODL_HOME}/bin/karaf
