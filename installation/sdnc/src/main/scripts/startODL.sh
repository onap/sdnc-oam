#!/bin/bash

###
# ============LICENSE_START=======================================================
# SDN-C
# ================================================================================
# Copyright (C) 2020 Samsung Electronics
# Copyright (C) 2017 AT&T Intellectual Property. All rights reserved.
# Copyright (C) 2020 Highstreet Technologies
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
# A single entry point script that can be used in Kubernetes based deployments (via OOM) and standalone docker deployments.
# Please see https://wiki.onap.org/display/DW/startODL.sh+-+Important+Environment+variables+and+their+description for more details

# Functions

# Test if repository exists, like this mvn:org.onap.ccsdk.features.sdnr.wt/sdnr-wt-devicemanager-oran-feature/0.7.2/xml/features
# $1 repository
function isRepoExisting() {
  REPO=$(echo $1 | sed -E "s#mvn:(.*)/xml/features\$#\1#")
  OIFS="$IFS"
  IFS='/' parts=($REPO)
  IFS="$OIFS"
  path="$ODL_HOME/system/"${parts[0]//./\/}"/"${parts[1]}"/"${parts[2]}
  [ -d "$path" ]
}

# Add features repository to karaf featuresRepositories configuration
# $1 repositories to be added
function addRepository() {
  CFG=$ODL_FEATURES_BOOT_FILE
  ORIG=$CFG.orig
  if isRepoExisting "$1" ; then
    echo "Add repository: $1"
    sed -i "\|featuresRepositories|s|$|, $1|" $CFG
  else
    echo "Repo does not exist: $1"
  fi
}

# Append features to karaf boot feature configuration
# $1 additional feature to be added
# $2 repositories to be added (optional)
function addToFeatureBoot() {
  CFG=$ODL_FEATURES_BOOT_FILE
  ORIG=$CFG.orig
  if [ -n "$2" ] ; then
    echo "Add repository: $2"
    mv $CFG $ORIG
    cat $ORIG | sed -e "\|featuresRepositories|s|$|,$2|" > $CFG
  fi
  echo "Add boot feature: $1"
  mv $CFG $ORIG
  cat $ORIG | sed -e "\|featuresBoot *=|s|$|,$1|" > $CFG
}

# Append features to karaf boot feature configuration
# $1 search pattern
# $2 replacement
function replaceFeatureBoot() {
  CFG=$ODL_HOME/etc/org.apache.karaf.features.cfg
  ORIG=$CFG.orig
  echo "Replace boot feature $1 with: $2"
  sed -i "/featuresBoot/ s/$1/$2/g" $CFG
}

# Remove all sdnc specific features
function cleanupFeatureBoot() {
  echo "Remove northbound bootfeatures "
  sed -i "/featuresBoot/ s/,ccsdk-sli-core-all.*$//g" $ODL_FEATURES_BOOT_FILE
}

function initialize_sdnr() {
  echo "SDN-R Database Initialization"
  INITCMD="$JAVA_HOME/bin/java -jar "
  INITCMD+="$ODL_HOME/system/org/onap/ccsdk/features/sdnr/wt/sdnr-wt-data-provider-setup/$CCSDKFEATUREVERSION/sdnr-dmt.jar "
  INITCMD+="$SDNRDBCOMMAND"
  echo "Execute: $INITCMD"
  n=0
  until [ $n -ge 5 ] ; do
    $INITCMD && break
    n=$[$n+1]
    sleep 15
  done
  return $?
}

function install_sdnrwt_features() {
  # Repository setup provided via sdnc dockerfile
  if $SDNRWT; then
    addRepository $SDNRDM_BASE_REPO
    addRepository $SDNRDM_ONF_REPO

    if $SDNRONLY; then
      cleanupFeatureBoot
    fi
    if $SDNRDM; then
      addToFeatureBoot "$SDNRDM_BOOTFEATURES"
    else
      addToFeatureBoot "$SDNRWT_BOOTFEATURES"
    fi
  fi
}

function install_sdnr_northbound_features() {
  addToFeatureBoot "$SDNR_NORTHBOUND_BOOTFEATURES" 
}

# Reconfigure ODL from default single node configuration to cluster

function enable_odl_cluster() {
  if [ -z $SDNC_REPLICAS ]; then
     echo "SDNC_REPLICAS is not configured in Env field"
     exit
  fi

  # ODL NETCONF setup
  echo "Installing Opendaylight cluster features for mdsal and netconf"
  
  #Be sure to remove feature odl-netconf-connector-all from list
  replaceFeatureBoot "odl-netconf-connector-all,"

  echo "Installing Opendaylight cluster features"
  replaceFeatureBoot odl-netconf-topology odl-netconf-clustered-topology
  replaceFeatureBoot odl-mdsal-all odl-mdsal-all,odl-mdsal-clustering
  addToFeatureBoot odl-jolokia
  #${ODL_HOME}/bin/client feature:install odl-mdsal-clustering
  #${ODL_HOME}/bin/client feature:install odl-jolokia

  # ODL Cluster or Geo cluster configuration
  
  echo "Update cluster information statically"
  fqdn=$(hostname -f)
  echo "Get current fqdn ${fqdn}"

  # Extract node index using first digit after "-"
  # Example 2 from "sdnr-2.logo.ost.das.r32.com"
  node_index=`(echo ${fqdn} | sed -r 's/.*-([0-9]).*/\1/g')`
  member_offset=1

  if $GEO_ENABLED; then
    echo "This is a Geo cluster"

    if [ -z $IS_PRIMARY_CLUSTER ] || [ -z $MY_ODL_CLUSTER ] || [ -z $PEER_ODL_CLUSTER ]; then
     echo "IS_PRIMARY_CLUSTER, MY_ODL_CLUSTER and PEER_ODL_CLUSTER must all be configured in Env field"
     return
    fi

    if $IS_PRIMARY_CLUSTER; then
       PRIMARY_NODE=${MY_ODL_CLUSTER}
       SECONDARY_NODE=${PEER_ODL_CLUSTER}
    else
       PRIMARY_NODE=${PEER_ODL_CLUSTER}
       SECONDARY_NODE=${MY_ODL_CLUSTER}
       member_offset=4
    fi

    node_list="${PRIMARY_NODE} ${SECONDARY_NODE}"

    ${SDNC_BIN}/configure_geo_cluster.sh $((node_index+member_offset)) ${node_list}
  else
    echo "This is a local cluster"
    node_list=""
    # SERVICE_NAME and NAMESPACE are used to create cluster node names and are provided via Helm charts in OOM environment
    if [ ! -z "$SERVICE_NAME" ] && [ ! -z "$NAMESPACE" ]; then
       # Extract node name minus the index
       # Example sdnr from "sdnr-2.logo.ost.das.r32.com"
       node_name=($(echo ${fqdn} | sed 's/-[0-9].*$//g'))
       for ((i=0;i<${SDNC_REPLICAS};i++));
       do
         node_list="${node_list} ${node_name}-$i.${SERVICE_NAME}-cluster.${NAMESPACE}"
       done
       ${ODL_HOME}/bin/configure_cluster.sh $((node_index+1)) ${node_list}
    elif [ -z "$SERVICE_NAME" ] && [ -z "$NAMESPACE" ]; then
       # Hostname is used in Standalone environment to create cluster node names
       for ((i=0;i<${SDNC_REPLICAS};i++));
       do
         #assemble node list by replacing node-index in hostname with "i"
         node_name=`(echo ${fqdn} | sed -r "s/-[0-9]/-$i/g")`
         node_list="${node_list} ${node_name}"
       done
       ${ODL_HOME}/bin/configure_cluster.sh $((node_index+1)) ${node_list}
    else
       echo "Unhandled cluster scenario. Terminating the container" 
       echo "Any one of the below 2 conditions should be satisfied for successfully enabling cluster mode : "
       echo "1. OOM Environment - Both SERVICE_NAME and NAMESPACE environment variables have to be set."
       echo "2. Docker (standalone) Environment - Neither of SERVICE_NAME and NAMESPACE have to be set."
       echo "Current configuration - SERVICE_NAME = $SERVICE_NAME  NAMESPACE = $NAMESPACE"
       exit $NOTOK
    fi
  fi
}


# Install SDN-C platform components if not already installed and start container

# -----------------------
# Main script starts here

ODL_HOME=${ODL_HOME:-/opt/opendaylight/current}
ODL_FEATURES_BOOT_FILE=$ODL_HOME/etc/org.apache.karaf.features.cfg
#
ODL_REMOVEIDMDB=${ODL_REMOVEIDMDB:-false}

ODL_ADMIN_USERNAME=${ODL_ADMIN_USERNAME:-admin}
if $ODL_REMOVEIDMDB ; then
   echo "Remove odl idmdb"
   rm $ODL_HOME/data/idmlight.db.mv.db
   ODL_ADMIN_PASSWORD=${ODL_ADMIN_PASSWORD:-admin}
else
   ODL_ADMIN_PASSWORD=${ODL_ADMIN_PASSWORD:-Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U}
fi
ODL_ADMIN_PASSWORD=${ODL_ADMIN_PASSWORD:-Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U}
SDNC_HOME=${SDNC_HOME:-/opt/onap/sdnc}
SDNC_BIN=${SDNC_BIN:-/opt/onap/sdnc/bin}
# Whether to intialize MYSql DB or not. Default is to initialize
SDNC_DB_INIT=${SDNC_DB_INIT:-false}
CCSDK_HOME=${CCSDK_HOME:-/opt/onap/ccsdk}
JDEBUG=${JDEBUG:-false}
MYSQL_PASSWD=${MYSQL_PASSWD:-openECOMP1.0}
ENABLE_ODL_CLUSTER=${ENABLE_ODL_CLUSTER:-false}
GEO_ENABLED=${GEO_ENABLED:-false}
SDNC_AAF_ENABLED=${SDNC_AAF_ENABLED:-false}
IS_PRIMARY_CLUSTER=${IS_PRIMARY_CLUSTER:-false}
MY_ODL_CLUSTER=${MY_ODL_CLUSTER:-127.0.0.1}
INSTALLED_DIR=${INSTALLED_FILE:-/opt/opendaylight/current/daexim}
SDNRWT=${SDNRWT:-false}
SDNRWT_BOOTFEATURES=${SDNRWT_BOOTFEATURES:-sdnr-wt-feature-aggregator}
SDNRDM=${SDNRDM:-false}
# Add devicemanager base and specific repositories
SDNRDM_BASE_REPO=${SDNRDM_BASE_REPO:-mvn:org.onap.ccsdk.features.sdnr.wt/sdnr-wt-feature-aggregator-devicemanager-base/$CCSDKFEATUREVERSION/xml/features}
SDNRDM_ONF_REPO=${SDNRDM_ONF_REPO:-mvn:org.onap.ccsdk.features.sdnr.wt/sdnr-wt-devicemanager-onf-feature/$CCSDKFEATUREVERSION/xml/features}
# Add devicemanager features
SDNRDM_SDM_LIST=${SDNRDM_SDM_LIST:-sdnr-wt-devicemanager-onf-feature}
SDNRDM_BOOTFEATURES=${SDNRDM_BOOTFEATURES:-sdnr-wt-feature-aggregator-devicemanager-base, ${SDNRDM_SDM_LIST}}
# Whether to Initialize the ElasticSearch DB.
SDNRINIT=${SDNRINIT:-false}
SDNRONLY=${SDNRONLY:-false}
SDNRDBURL=${SDNRDBURL:-http://sdnrdb:9200}
SDNRDBCOMMAND=${SDNRDBCOMMAND:--c init -db $SDNRDBURL -dbu $SDNRDBUSERNAME -dbp $SDNRDBPASSWORD $SDNRDBPARAMETER}

SDNR_NORTHBOUND=${SDNR_NORTHBOUND:-false}
SDNR_NORTHBOUND_BOOTFEATURES=${SDNR_NORTHBOUND_BOOTFEATURES:-sdnr-northbound-all}
NOTOK=1
export ODL_ADMIN_PASSWORD ODL_ADMIN_USERNAME

if $JDEBUG ; then
    echo "Activate remote debugging"
    #JSTADTPOLICYFILE="$ODL_HOME/etc/tools.policy"
    #echo -e "grant codebase \"file:${JAVA_HOME}/lib/tools.jar\" {\n  permission java.security.AllPermission;\n };" > $JSTADTPOLICYFILE
    #sleep 1
    #$JAVA_HOME/bin/jstatd -p 1089 -J-Djava.security.policy=$JSTADTPOLICYFILE &
    EXTRA_JAVA_OPTS+=" -Dcom.sun.management.jmxremote.port=1090"
    EXTRA_JAVA_OPTS+=" -Dcom.sun.management.jmxremote.rmi.port=1090"
    EXTRA_JAVA_OPTS+=" -Djava.rmi.server.hostname=$HOSTNAME"
    EXTRA_JAVA_OPTS+=" -Dcom.sun.management.jmxremote.local.only=false"
    EXTRA_JAVA_OPTS+=" -Dcom.sun.management.jmxremote.ssl=false"
    EXTRA_JAVA_OPTS+=" -Dcom.sun.management.jmxremote.authenticate=false"
    export EXTRA_JAVA_OPTS
fi


echo "Settings:"
echo "  SDNC_BIN=$SDNC_BIN"
echo "  SDNC_HOME=$SDNC_HOME"
echo "  SDNC_DB_INIT=$SDNC_DB_INIT"
echo "  ODL_CERT_DIR=$ODL_CERT_DIR"
echo "  CCSDKFEATUREVERSION=$CCSDKFEATUREVERSION"
echo "  ENABLE_ODL_CLUSTER=$ENABLE_ODL_CLUSTER"
echo "  ODL_REMOVEIDMDB=$ODL_REMOVEIDMDB"
echo "  SDNC_REPLICAS=$SDNC_REPLICAS"
echo "  SDNRWT=$SDNRWT"
echo "  SDNRDM=$SDNRDM"
echo "  SDNRONLY=$SDNRONLY"
echo "  SDNRINIT=$SDNRINIT"
echo "  SDNRDBURL=$SDNRDBURL"
echo "  SDNRDBUSERNAME=$SDNRDBUSERNAME"
echo "  GEO_ENABLED=$GEO_ENABLED"
echo "  IS_PRIMARY_CLUSTER=$IS_PRIMARY_CLUSTER"
echo "  MY_ODL_CLUSTER=$MY_ODL_CLUSTER"
echo "  PEER_ODL_CLUSTER=$PEER_ODL_CLUSTER"
echo "  SDNR_NORTHBOUND=$SDNR_NORTHBOUND"
echo "  AAF_ENABLED=$SDNC_AAF_ENABLED"
echo "  SERVICE_NAME=$SERVICE_NAME"
echo "  NAMESPACE=$NAMESPACE"

if $SDNC_AAF_ENABLED; then
	export SDNC_AAF_STORE_DIR=/opt/app/osaaf/local
	export SDNC_AAF_CONFIG_DIR=/opt/app/osaaf/local
	export SDNC_KEYPASS=`cat /opt/app/osaaf/local/.pass`
	export SDNC_KEYSTORE=org.onap.sdnc.p12
	sed -i '/cadi_prop_files/d' $ODL_HOME/etc/system.properties
	echo "cadi_prop_files=$SDNC_AAF_CONFIG_DIR/org.onap.sdnc.props" >> $ODL_HOME/etc/system.properties

	sed -i '/org.ops4j.pax.web.ssl.keystore/d' $ODL_HOME/etc/custom.properties
	sed -i '/org.ops4j.pax.web.ssl.password/d' $ODL_HOME/etc/custom.properties
	sed -i '/org.ops4j.pax.web.ssl.keypassword/d' $ODL_HOME/etc/custom.properties
	echo org.ops4j.pax.web.ssl.keystore=$SDNC_AAF_STORE_DIR/$SDNC_KEYSTORE >> $ODL_HOME/etc/custom.properties
	echo org.ops4j.pax.web.ssl.password=$SDNC_KEYPASS >> $ODL_HOME/etc/custom.properties
	echo org.ops4j.pax.web.ssl.keypassword=$SDNC_KEYPASS >> $ODL_HOME/etc/custom.properties
fi

if $SDNRINIT ; then
  #One time intialization action
  initialize_sdnr
  init_result=$?
  echo "Result of init script: $init_result"
  if $SDNRWT ; then
    echo "Proceed to initialize sdnr"
  else
    exit $init_result
  fi
fi

# Check for MySQL DB connectivity only if SDNC_DB_INIT is set to "true" 
if $SDNC_DB_INIT; then
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
fi

if [ ! -d ${INSTALLED_DIR} ]
then
    mkdir -p ${INSTALLED_DIR}
fi

if [ ! -f ${SDNC_HOME}/.installed ]
then
    # for integration testing. In OOM, a separate job takes care of installing it.
    if $SDNC_DB_INIT; then
      echo "Installing SDN-C database"
      ${SDNC_HOME}/bin/installSdncDb.sh
    fi
    echo "Installing SDN-C keyStore\n"
    ${SDNC_HOME}/bin/addSdncKeyStore.sh
    echo "Installing A1-adapter trustStore\n"
    ${SDNC_HOME}/bin/addA1TrustStore.sh

    if [ -x ${SDNC_HOME}/svclogic/bin/install.sh ]
    then
      echo "Installing directed graphs"
      ${SDNC_HOME}/svclogic/bin/install.sh
    fi

  if $ENABLE_ODL_CLUSTER ; then enable_odl_cluster ; fi

  if $SDNRWT ; then install_sdnrwt_features ; fi

  if $SDNR_NORTHBOUND ; then install_sdnr_northbound_features ; fi
  echo "Installed at `date`" > ${SDNC_HOME}/.installed
fi

#cp /opt/opendaylight/current/certs/* /tmp
#cp /var/custom-certs/* /tmp

if [ -n "$OVERRIDE_FEATURES_BOOT" ] ; then
  echo "Override features boot: $OVERRIDE_FEATURES_BOOT"
  sed -i "/$FEATURESBOOTMARKER/c\featuresBoot = $OVERRIDE_FEATURES_BOOT" $ODL_FEATURES_BOOT_FILE
fi

# Odl configuration done
ODL_REPOSITORIES_BOOT=$(sed -n "/$REPOSITORIESBOOTMARKER/p" $ODL_FEATURES_BOOT_FILE)
ODL_FEATURES_BOOT=$(sed -n "/$FEATURESBOOTMARKER/p" $ODL_FEATURES_BOOT_FILE)
export ODL_FEATURES_BOOT

# Create ODL data log directory (it nornally is created after karaf
# is started, but needs to exist before installCerts.py runs)
if [ -z "$ODL_CERT_DIR" ] ; then
  echo "No certs provided. Skip installation."
else
  echo "Start background cert installer"
  mkdir -p /opt/opendaylight/data/log
  nohup python3 ${SDNC_BIN}/installCerts.py &
fi

echo "Startup opendaylight"
echo $ODL_REPOSITORIES_BOOT
echo $ODL_FEATURES_BOOT
exec ${ODL_HOME}/bin/karaf server
