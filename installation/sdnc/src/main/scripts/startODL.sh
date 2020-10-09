#!/bin/sh
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
isRepoExisting() {
  REPO=$(echo "$1" | sed -E "s#mvn:(.*)/xml/features\$#\1#")
  OIFS="$IFS"
  IFS='/' 
  set parts $REPO
  IFS="$OIFS"
  path="$ODL_HOME/system/$(echo "$2" | tr '.' '/')/$3/$4"
  [ -d "$path" ]
}

# Add features repository to karaf featuresRepositories configuration
# $1 repositories to be added
addRepository() {
  CFG=$ODL_FEATURES_BOOT_FILE
  ORIG=$CFG.orig
  if isRepoExisting "$1" ; then
    printf "%s\n" "Add repository: $1"
    sed -i "\|featuresRepositories|s|$|, $1|" "$CFG"
  else
    printf "%s\n" "Repo does not exist: $1"
  fi
}

# Append features to karaf boot feature configuration
# $1 additional feature to be added
# $2 repositories to be added (optional)
addToFeatureBoot() {
  CFG=$ODL_FEATURES_BOOT_FILE
  ORIG=$CFG.orig
  if [ -n "$2" ] ; then
    printf "%s\n" "Add repository: $2"
    mv "$CFG" "$ORIG"
    sed -e "\|featuresRepositories|s|$|,$2|" "$ORIG" > "$CFG"
  fi
  printf "%s\n" "Add boot feature: $1"
  mv "$CFG" "$ORIG"
  sed -e "\|featuresBoot *=|s|$|,$1|" "$ORIG" > "$CFG"
}

# Append features to karaf boot feature configuration
# $1 search pattern
# $2 replacement
replaceFeatureBoot() {
  CFG="$ODL_HOME"/etc/org.apache.karaf.features.cfg
  ORIG=$CFG.orig
  printf "%s %s\n" "Replace boot feature $1 with: $2"
  sed -i "/featuresBoot/ s/$1/$2/g" "$CFG"
}

# Remove all sdnc specific features
cleanupFeatureBoot() {
  printf "Remove northbound bootfeatures \n"
  sed -i "/featuresBoot/ s/,ccsdk-sli-core-all.*$//g" "$ODL_FEATURES_BOOT_FILE"
}

initialize_sdnr() {
  printf "SDN-R Database Initialization"
  INITCMD="$JAVA_HOME/bin/java -jar "
  INITCMD="${INITCMD} $ODL_HOME/system/org/onap/ccsdk/features/sdnr/wt/sdnr-wt-data-provider-setup/$CCSDKFEATUREVERSION/sdnr-dmt.jar "
  INITCMD="${INITCMD} $SDNRDBCOMMAND"
  printf "%s\n" "Execute: $INITCMD"
  n=0
  until [ $n -ge 5 ] ; do
    $INITCMD && break
    n=$((n+1))
    sleep 15
  done
  return $?
}

install_sdnrwt_features() {
  # Repository setup provided via sdnc dockerfile
  if $SDNRWT; then
    addRepository "$SDNRDM_BASE_REPO"
    addRepository "$SDNRDM_ONF_REPO"

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

install_sdnr_northbound_features() {
  addToFeatureBoot "$SDNR_NORTHBOUND_BOOTFEATURES" 
}

# Reconfigure ODL from default single node configuration to cluster

enable_odl_cluster() {
  if [ -z "$SDNC_REPLICAS" ]; then
     printf "SDNC_REPLICAS is not configured in Env field"
     exit
  fi

  # ODL NETCONF setup
  printf "Installing Opendaylight cluster features for mdsal and netconf\n"
  
  #Be sure to remove feature odl-netconf-connector-all from list
  replaceFeatureBoot "odl-netconf-connector-all,"

  printf "Installing Opendaylight cluster features\n"
  replaceFeatureBoot odl-netconf-topology odl-netconf-clustered-topology
  replaceFeatureBoot odl-mdsal-all odl-mdsal-all,odl-mdsal-clustering
  addToFeatureBoot odl-jolokia
  #${ODL_HOME}/bin/client feature:install odl-mdsal-clustering
  #${ODL_HOME}/bin/client feature:install odl-jolokia

  # ODL Cluster or Geo cluster configuration
  
  printf "Update cluster information statically\n"
  fqdn=$(hostname -f)
  printf "%s\n" "Get current fqdn ${fqdn}"

  # Extract node index using first digit after "-"
  # Example 2 from "sdnr-2.logo.ost.das.r32.com"
  node_index=$(echo "${fqdn}" | sed -r 's/.*-([0-9]).*/\1/g')
  member_offset=1

  if $GEO_ENABLED; then
    printf "This is a Geo cluster\n"

    if [ -z "$IS_PRIMARY_CLUSTER" ] || [ -z "$MY_ODL_CLUSTER" ] || [ -z "$PEER_ODL_CLUSTER" ]; then
     printf "IS_PRIMARY_CLUSTER, MY_ODL_CLUSTER and PEER_ODL_CLUSTER must all be configured in Env field\n"
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

    "${SDNC_BIN}"/configure_geo_cluster.sh $((node_index+member_offset)) "${node_list}"
  else
    printf "This is a local cluster\n"
    i=0
    node_list=""
    # SERVICE_NAME and NAMESPACE are used to create cluster node names and are provided via Helm charts in OOM environment
    if [ ! -z "$SERVICE_NAME" ] && [ ! -z "$NAMESPACE" ]; then
       # Extract node name minus the index
       # Example sdnr from "sdnr-2.logo.ost.das.r32.com"
       node_name=$(echo "${fqdn}" | sed 's/-[0-9].*$//g')
       while [ $i -lt "$SDNC_REPLICAS" ]; do
         node_list="${node_list} ${node_name}-$i.${SERVICE_NAME}-cluster.${NAMESPACE}"
         i=$(("$i" + 1))
       done
       "${ODL_HOME}"/bin/configure_cluster.sh $((node_index+1)) "${node_list}"
    elif [ -z "$SERVICE_NAME" ] && [ -z "$NAMESPACE" ]; then
      # Hostname is used in Standalone environment to create cluster node names
       while [ $i -lt "$SDNC_REPLICAS" ]; do
         #assemble node list by replacing node-index in hostname with "i"
         node_name=$(echo "${fqdn}" | sed -r "s/-[0-9]/-$i/g")
         node_list="${node_list} ${node_name}"
         i=$(("$i" + 1))
       done
       "${ODL_HOME}"/bin/configure_cluster.sh $((node_index+1)) "${node_list}"
    elif [ -z "$SERVICE_NAME" ] || [ -z "$NAMESPACE" ]; then
        printf "Only one of SERVICE_NAME or NAMESPACE has been set. SERVICE_NAME = $SERVICE_NAME  NAMESPACE = $NAMESPACE\n"
        printf "Both SERVICE_NAME and NAMESPACE environment variables have to be set. Terminating the container\n"
        exit $NOTOK
    else
        printf "Unhandled cluster scenario. Exiting container\n"
        exit $NOTOK
    fi
  fi
}


# Install SDN-C platform components if not already installed and start container

# -----------------------
# Main script starts here
printf "Installing SDNC/R from startODL.sh script\n"
ODL_HOME=${ODL_HOME:-/opt/opendaylight/current}
ODL_FEATURES_BOOT_FILE=$ODL_HOME/etc/org.apache.karaf.features.cfg
#
ODL_REMOVEIDMDB=${ODL_REMOVEIDMDB:-false}

ODL_ADMIN_USERNAME=${ODL_ADMIN_USERNAME:-admin}
if $ODL_REMOVEIDMDB ; then
   printf "Remove odl idmdb"
   rm "$ODL_HOME"/data/idmlight.db.mv.db
   ODL_ADMIN_PASSWORD=${ODL_ADMIN_PASSWORD:-admin}
else
   ODL_ADMIN_PASSWORD=${ODL_ADMIN_PASSWORD:-Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U}
fi
ODL_ADMIN_PASSWORD=${ODL_ADMIN_PASSWORD:-Kp8bJ4SXszM0WXlhak3eHlcse2gAw84vaoGGmJvUy2U}
SDNC_HOME=${SDNC_HOME:-/opt/onap/sdnc}
SDNC_BIN=${SDNC_BIN:-/opt/onap/sdnc/bin}
# Whether to initialize MySQL DB or not. In standalone mode, will be initialized via docker-compose
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
    printf "Activate remote debugging\n"
    #JSTADTPOLICYFILE="$ODL_HOME/etc/tools.policy"
    #echo -e "grant codebase \"file:${JAVA_HOME}/lib/tools.jar\" {\n  permission java.security.AllPermission;\n };" > $JSTADTPOLICYFILE
    #sleep 1
    #$JAVA_HOME/bin/jstatd -p 1089 -J-Djava.security.policy=$JSTADTPOLICYFILE &
    EXTRA_JAVA_OPTS="${EXTRA_JAVA_OPTS} -Dcom.sun.management.jmxremote.port=1090"
    EXTRA_JAVA_OPTS="${EXTRA_JAVA_OPTS} -Dcom.sun.management.jmxremote.rmi.port=1090"
    EXTRA_JAVA_OPTS="${EXTRA_JAVA_OPTS} -Djava.rmi.server.hostname=$(hostname)  "
    EXTRA_JAVA_OPTS="${EXTRA_JAVA_OPTS} -Dcom.sun.management.jmxremote.local.only=false"
    EXTRA_JAVA_OPTS="${EXTRA_JAVA_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
    EXTRA_JAVA_OPTS="${EXTRA_JAVA_OPTS} -Dcom.sun.management.jmxremote.authenticate=false"
    export EXTRA_JAVA_OPTS
fi


printf "Settings:\n"
printf "%s\n" "  SDNC_BIN=$SDNC_BIN"
printf "%s\n" "  SDNC_HOME=$SDNC_HOME"
printf "%s\n" "  SDNC_DB_INIT=$SDNC_DB_INIT"
printf "%s\n" "  ODL_CERT_DIR=$ODL_CERT_DIR"
printf "%s\n" "  CCSDKFEATUREVERSION=$CCSDKFEATUREVERSION"
printf "%s\n" "  ENABLE_ODL_CLUSTER=$ENABLE_ODL_CLUSTER"
printf "%s\n" "  ODL_REMOVEIDMDB=$ODL_REMOVEIDMDB"
printf "%s\n" "  SDNC_REPLICAS=$SDNC_REPLICAS"
printf "%s\n" "  SDNRWT=$SDNRWT"
printf "%s\n" "  SDNRDM=$SDNRDM"
printf "%s\n" "  SDNRONLY=$SDNRONLY"
printf "%s\n" "  SDNRINIT=$SDNRINIT"
printf "%s\n" "  SDNRDBURL=$SDNRDBURL"
printf "%s\n" "  SDNRDBUSERNAME=$SDNRDBUSERNAME"
printf "%s\n" "  GEO_ENABLED=$GEO_ENABLED"
printf "%s\n" "  IS_PRIMARY_CLUSTER=$IS_PRIMARY_CLUSTER"
printf "%s\n" "  MY_ODL_CLUSTER=$MY_ODL_CLUSTER"
printf "%s\n" "  PEER_ODL_CLUSTER=$PEER_ODL_CLUSTER"
printf "%s\n" "  SDNR_NORTHBOUND=$SDNR_NORTHBOUND"
printf "%s\n" "  AAF_ENABLED=$SDNC_AAF_ENABLED"
printf "%s\n" "  SERVICE_NAME=$SERVICE_NAME"
printf "%s\n" "  NAMESPACE=$NAMESPACE"

if "$SDNC_AAF_ENABLED"; then
	export SDNC_AAF_STORE_DIR=/opt/app/osaaf/local
	export SDNC_AAF_CONFIG_DIR=/opt/app/osaaf/local
	export SDNC_KEYPASS=$(cat /opt/app/osaaf/local/.pass)
	export SDNC_KEYSTORE=org.onap.sdnc.p12
	sed -i '/cadi_prop_files/d' "$ODL_HOME"/etc/system.properties
	echo "cadi_prop_files=$SDNC_AAF_CONFIG_DIR/org.onap.sdnc.props" >> "$ODL_HOME"/etc/system.properties

	sed -i '/org.ops4j.pax.web.ssl.keystore/d' "$ODL_HOME"/etc/custom.properties
	sed -i '/org.ops4j.pax.web.ssl.password/d' "$ODL_HOME"/etc/custom.properties
	sed -i '/org.ops4j.pax.web.ssl.keypassword/d' "$ODL_HOME"/etc/custom.properties
	echo "org.ops4j.pax.web.ssl.keystore=$SDNC_AAF_STORE_DIR/$SDNC_KEYSTORE" >> "$ODL_HOME"/etc/custom.properties
	echo "org.ops4j.pax.web.ssl.password=$SDNC_KEYPASS" >> "$ODL_HOME"/etc/custom.properties
	echo "org.ops4j.pax.web.ssl.keypassword=$SDNC_KEYPASS" >> "$ODL_HOME"/etc/custom.properties
fi

if $SDNRINIT ; then
  #One time intialization action
  initialize_sdnr
  init_result=$?
  printf "%s\n" "Result of init script: $init_result"
  if $SDNRWT ; then
    printf "Proceed to initialize sdnr\n"
  else
    exit $init_result
  fi
fi

# Check for MySQL DB connectivity only if SDNC_DB_INIT is set to "true" 
if $SDNC_DB_INIT; then
#
# Wait for database
#
  printf "Waiting for mysql"
  until mysql -h dbhost -u root -p"${MYSQL_PASSWD}" mysql > /dev/null 2>&1 
  do
    printf "."
    sleep 1
  done
  printf "\nmysql ready"
fi

if [ ! -d "${INSTALLED_DIR}" ]
then
    mkdir -p "${INSTALLED_DIR}"
fi

if [ ! -f "${SDNC_HOME}"/.installed ]
then
    # for integration testing. In OOM, a separate job takes care of installing it.
    if $SDNC_DB_INIT; then
      printf "Installing SDN-C database\n"
      "${SDNC_HOME}"/bin/installSdncDb.sh
    fi
    printf "Installing SDN-C keyStore\n"
    "${SDNC_HOME}"/bin/addSdncKeyStore.sh
    printf "Installing A1-adapter trustStore\n"
    "${SDNC_HOME}"/bin/addA1TrustStore.sh

    if [ -x "${SDNC_HOME}"/svclogic/bin/install.sh ]
    then
      printf "Installing directed graphs\n"
      "${SDNC_HOME}"/svclogic/bin/install.sh
    fi

  if $SDNRWT ; then install_sdnrwt_features ; fi
  # The enable_odl_cluster call should not be moved above this line as the cleanFeatureBoot will overwrite entries. Ex: odl-jolokia
  if $ENABLE_ODL_CLUSTER ; then enable_odl_cluster ; fi

  if $SDNR_NORTHBOUND ; then install_sdnr_northbound_features ; fi
  printf "%s" "Installed at $(date)" > "${SDNC_HOME}"/.installed
fi

#cp /opt/opendaylight/current/certs/* /tmp
#cp /var/custom-certs/* /tmp

if [ -n "$OVERRIDE_FEATURES_BOOT" ] ; then
  printf "%s\n" "Override features boot: $OVERRIDE_FEATURES_BOOT"
  sed -i "/$FEATURESBOOTMARKER/c\featuresBoot = $OVERRIDE_FEATURES_BOOT" "$ODL_FEATURES_BOOT_FILE"
fi

# Odl configuration done
ODL_REPOSITORIES_BOOT=$(sed -n "/$REPOSITORIESBOOTMARKER/p" "$ODL_FEATURES_BOOT_FILE")
ODL_FEATURES_BOOT=$(sed -n "/$FEATURESBOOTMARKER/p" "$ODL_FEATURES_BOOT_FILE")
export ODL_FEATURES_BOOT

# Create ODL data log directory (it nornally is created after karaf
# is started, but needs to exist before installCerts.py runs)
if [ -z "$ODL_CERT_DIR" ] ; then
  printf "No certs provided. Skip installation.\n"
else
  printf "Start background cert installer\n"
  mkdir -p /opt/opendaylight/data/log
  nohup python3 "${SDNC_BIN}"/installCerts.py &
fi

printf "Startup opendaylight\n"
printf "%s\n" "$ODL_REPOSITORIES_BOOT"
printf "%s\n" "$ODL_FEATURES_BOOT"
exec "${ODL_HOME}"/bin/karaf server
