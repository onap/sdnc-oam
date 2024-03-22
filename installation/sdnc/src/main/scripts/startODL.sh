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

initialize_sdnrdb() {
  printf "SDN-R Database Initialization"
  INITCMD="$JAVA_HOME/bin/java -jar "
  FN=$(find "$ODL_HOME/system" -name "sdnr-wt-data-provider-setup-*.jar")
  INITCMD="${INITCMD} ${FN} $SDNRDBCOMMAND"
  printf "%s\n" "Execute: $INITCMD"
  n=0
  until [ $n -ge 5 ] ; do
    $INITCMD
    ret=$?
    if [ $ret -eq 0 ] ; then
      break;
    fi
    n=$((n+1))
    sleep 15
  done
  return $ret
}

install_sdnrwt_features() {
  # Repository setup provided via sdnc dockerfile
  if $SDNRWT; then
    if $SDNRONLY; then
      cleanupFeatureBoot
    fi
    addToFeatureBoot "$SDNRDM_BOOTFEATURES"
    if ! $SDNRDM; then
      addToFeatureBoot "$SDNRODLUX_BOOTFEATURES"
    fi
    if $SDNR_NETCONF_CALLHOME_ENABLED; then
      addToFeatureBoot "$SDNR_NETCONF_CALLHOME_FEATURE"
    fi
  fi
}
install_sdnr_oauth_features() {
  addToFeatureBoot "$SDNROAUTH_BOOTFEATURES"
}
install_sdnr_northbound_features() {
  addToFeatureBoot "$SDNR_NORTHBOUND_BOOTFEATURES"
}
install_a1_northbound_features() {
  addToFeatureBoot "$A1_ADAPTER_NORTHBOUND_BOOTFEATURES"
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
         i=$(($i + 1))
       done
       "${ODL_HOME}"/bin/configure_cluster.sh $((node_index+1)) "${node_list}"
    elif [ -z "$SERVICE_NAME" ] && [ -z "$NAMESPACE" ]; then
      # Hostname is used in Standalone environment to create cluster node names
       while [ $i -lt "$SDNC_REPLICAS" ]; do
         #assemble node list by replacing node-index in hostname with "i"
         node_name=$(echo "${fqdn}" | sed -r "s/-[0-9]/-$i/g")
         node_list="${node_list} ${node_name}"
         i=$(($i + 1))
       done
       "${ODL_HOME}"/bin/configure_cluster.sh $((node_index+1)) "${node_list}"
    else
       printf "Unhandled cluster scenario. Terminating the container\n"
       printf "Any one of the below 2 conditions should be satisfied for successfully enabling cluster mode : \n"
       printf "1. OOM Environment - Both SERVICE_NAME and NAMESPACE environment variables have to be set.\n"
       printf "2. Docker (standalone) Environment - Neither of SERVICE_NAME and NAMESPACE have to be set.\n"
       printf "Current configuration - SERVICE_NAME = $SERVICE_NAME  NAMESPACE = $NAMESPACE\n"
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
FEATURESBOOTMARKER="featuresBoot *="
REPOSITORIESBOOTMARKER="featuresRepositories *="

ODL_ADMIN_USERNAME=${ODL_ADMIN_USERNAME:-admin}
ODL_REMOVEIDMDB=${ODL_REMOVEIDMDB:-true}

if $ODL_REMOVEIDMDB ; then
  if [ -f $ODL_HOME/data/idmlight.db.mv.db ]; then
    rm $ODL_HOME/data/idmlight.db.mv.db
  fi
fi

CCSDK_HOME=${CCSDK_HOME:-/opt/onap/ccsdk}
SDNC_HOME=${SDNC_HOME:-/opt/onap/sdnc}
SDNC_BIN=${SDNC_BIN:-/opt/onap/sdnc/bin}
JDEBUG=${JDEBUG:-false}
SDNC_AAF_ENABLED=${SDNC_AAF_ENABLED:-false}
INSTALLED_DIR=${INSTALLED_FILE:-/opt/opendaylight/current/daexim}

# Whether to intialize MYSql DB or not. Default is to initialize
SDNC_DB_INIT=${SDNC_DB_INIT:-false}
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-openECOMP1.0}

IS_PRIMARY_CLUSTER=${IS_PRIMARY_CLUSTER:-false}
MY_ODL_CLUSTER=${MY_ODL_CLUSTER:-127.0.0.1}
ENABLE_ODL_CLUSTER=${ENABLE_ODL_CLUSTER:-false}
ENABLE_OAUTH=${ENABLE_OAUTH:-false}
ENABLE_ODLUX_RBAC=${ENABLE_ODLUX_RBAC:-false}
GEO_ENABLED=${GEO_ENABLED:-false}

SDNRWT=${SDNRWT:-false}
SDNRDM=${SDNRDM:-false}
SDNRODLUX_BOOTFEATURES=${SDNRODLUX_BOOTFEATURES:-sdnr-wt-helpserver-feature,sdnr-wt-odlux-core-feature,sdnr-wt-odlux-apps-feature}
SDNROAUTH_BOOTFEATURES=${SDNROAUTH_BOOTFEATURES:-sdnr-wt-feature-aggregator-oauth}
SDNR_NETCONF_CALLHOME_ENABLED=${SDNR_NETCONF_CALLHOME_ENABLED:-false}

# Add devicemanager features
SDNRDM_SDM_LIST=${SDNRDM_SDM_LIST:-sdnr-wt-feature-aggregator-devicemanager}
SDNRDM_BOOTFEATURES=${SDNRDM_BOOTFEATURES:-sdnr-wt-feature-aggregator-devicemanager-base,${SDNRDM_SDM_LIST}}

# Whether to Initialize the ElasticSearch DB.
SDNRINIT=${SDNRINIT:-false}
SDNRONLY=${SDNRONLY:-false}
SDNRDBTYPE=${SDNRDBTYPE:-ELASTICSEARCH}
SDNRDBURL=${SDNRDBURL:-http://sdnrdb:9200}
SDNRDBCOMMAND=${SDNRDBCOMMAND:--c init -db $SDNRDBURL -dbt $SDNRDBTYPE -dbu $SDNRDBUSERNAME -dbp $SDNRDBPASSWORD $SDNRDBPARAMETER}
SDNR_WEBSOCKET_PORT=${SDNR_WEBSOCKET_PORT:-8182}

SDNR_NORTHBOUND=${SDNR_NORTHBOUND:-false}
SDNR_NORTHBOUND_BOOTFEATURES=${SDNR_NORTHBOUND_BOOTFEATURES:-sdnr-northbound-all}
SDNR_NETCONF_CALLHOME_FEATURE=${SDNR_NETCONF_CALLHOME_FEATURE:-odl-netconf-callhome-ssh}

# if only SDNR features then do not start A1 adapter
if $SDNRONLY ; then
  A1_ADAPTER_NORTHBOUND=false
else
  A1_ADAPTER_NORTHBOUND=${A1_ADAPTER_NORTHBOUND:-true}
fi
A1_ADAPTER_NORTHBOUND_BOOTFEATURES=${A1_ADAPTER_NORTHBOUND_BOOTFEATURES:-a1-adapter-northbound}

NOTOK=1
#export for installCerts.py
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
printf "%s\n" "  ENABLE_ODL_CLUSTER=$ENABLE_ODL_CLUSTER"
printf "%s\n" "  ODL_REMOVEIDMDB=$ODL_REMOVEIDMDB"
printf "%s\n" "  SDNC_REPLICAS=$SDNC_REPLICAS"
printf "%s\n" "  ENABLE_OAUTH=$ENABLE_OAUTH"
printf "%s\n" "  ENABLE_ODLUX_RBAC=$ENABLE_ODLUX_RBAC"
printf "%s\n" "  SDNRWT=$SDNRWT"
printf "%s\n" "  SDNRDM=$SDNRDM"
printf "%s\n" "  SDNRONLY=$SDNRONLY"
printf "%s\n" "  SDNRINIT=$SDNRINIT"
printf "%s\n" "  SDNRDBURL=$SDNRDBURL"
printf "%s\n" "  SDNRDBTYPE=$SDNRDBTYPE"
printf "%s\n" "  SDNRDBUSERNAME=$SDNRDBUSERNAME"
printf "%s\n" "  GEO_ENABLED=$GEO_ENABLED"
printf "%s\n" "  IS_PRIMARY_CLUSTER=$IS_PRIMARY_CLUSTER"
printf "%s\n" "  MY_ODL_CLUSTER=$MY_ODL_CLUSTER"
printf "%s\n" "  PEER_ODL_CLUSTER=$PEER_ODL_CLUSTER"
printf "%s\n" "  SDNR_NORTHBOUND=$SDNR_NORTHBOUND"
printf "%s\n" "  AAF_ENABLED=$SDNC_AAF_ENABLED"
printf "%s\n" "  SERVICE_NAME=$SERVICE_NAME"
printf "%s\n" "  NAMESPACE=$NAMESPACE"
printf "%s\n" "  SDNR_NETCONF_CALLHOME_ENABLED=$SDNR_NETCONF_CALLHOME_ENABLED"

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
	echo "org.ops4j.pax.web.ssl.password=\"$SDNC_KEYPASS\"" >> "$ODL_HOME"/etc/custom.properties
	echo "org.ops4j.pax.web.ssl.keypassword=\"$SDNC_KEYPASS\"" >> "$ODL_HOME"/etc/custom.properties
fi

if $SDNRINIT ; then
  #One time intialization action
  initialize_sdnrdb
  init_result=$?
  printf "%s\n" "Result of init script: $init_result"
  if $SDNRWT ; then
    if [ $init_result -ne 0 ]; then
      echo "db not initialized. stopping container"
      exit $init_result
    fi
    printf "Proceed to initialize sdnr\n"
  else
    exit $init_result
  fi
fi

# do not start container if ADMIN_PASSWORD is not set
if [ -z "$ODL_ADMIN_PASSWORD" ]; then
  echo "ODL_ADMIN_PASSWORD is not set"
  exit 1
fi

# Check for MySQL DB connectivity only if SDNC_DB_INIT is set to "true"
if $SDNC_DB_INIT; then
#
# Wait for database
#
  printf "Waiting for mysql"
  until mysql -h dbhost -u root -p"${MYSQL_ROOT_PASSWORD}" -e "select 1" > /dev/null 2>&1
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
  if $ENABLE_OAUTH ; then
    cp $SDNC_HOME/data/oauth-aaa-app-config.xml $(find $ODL_HOME/system/org/opendaylight/aaa/ -name *aaa-app-config.xml)
    echo -e "\norg.ops4j.pax.web.session.cookie.comment = disable" >> $ODL_HOME/etc/org.ops4j.pax.web.cfg
    install_sdnr_oauth_features
  fi

  # The enable_odl_cluster call should not be moved above this line as the cleanFeatureBoot will overwrite entries. Ex: odl-jolokia
  if $ENABLE_ODL_CLUSTER ; then enable_odl_cluster ; fi

  if $SDNR_NORTHBOUND ; then install_sdnr_northbound_features ; fi
  if $A1_ADAPTER_NORTHBOUND ; then install_a1_northbound_features ; fi

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
  printf "Start monitoring certificate installation. \n"
  nohup sh "${SDNC_BIN}"/monitorCertsInstall.sh &
fi

printf "Startup opendaylight\n"
printf "%s\n" "$ODL_REPOSITORIES_BOOT"
printf "%s\n" "$ODL_FEATURES_BOOT"

exec "${ODL_HOME}"/bin/karaf server
