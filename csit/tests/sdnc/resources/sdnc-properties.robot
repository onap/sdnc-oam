*** Variables ***
# SDNC Configuration
${ODL_USER}                     %{ODL_USER}
${ODL_PASSWORD}                 %{ODL_PASSWORD}
${REQUEST_DATA_PATH}            %{REQUEST_DATA_PATH}
${SDNC_CONTAINER_NAME}          %{SDNC_CONTAINER_NAME}
${GRA_DATA_DIRECTORY}           %{WORKSPACE}/tests/sdnc/resources/grafiles
# ${SDNC_RESTCONF_URL}            http://localhost:8282/restconf
${SDNC_RESTCONF_URL}            http://localhost:8282/rests
${SDNC_HEALTHCHECK}             /operations/SLI-API:healthcheck
# ${SDNC_KEYSTORE_CONFIG_PATH}    /config/netconf-keystore:keystore
# ${SDNC_NETWORK_TOPOLOGY}        /config/network-topology:network-topology
# ${SDNC_MOUNT_PATH}              /config/network-topology:network-topology/topology/topology-netconf/node/PNFDemo
# ${PNFSIM_MOUNT_PATH}            /config/network-topology:network-topology/topology/topology-netconf/node/PNFDemo/yang-ext:mount/turing-machine:turing-machine
${SDNC_KEYSTORE_CONFIG_PATH}    /data/netconf-keystore:keystore?content=config
${SDNC_NETWORK_TOPOLOGY}        /data/network-topology:network-topology?content=config
${SDNC_MOUNT_PATH}              /data/network-topology:network-topology/topology=topology-netconf/node=PNFDemo
# ${PNFSIM_MOUNT_PATH}            /data/network-topology:network-topology/topology=topology-netconf/node=PNFDemo/yang-ext:mount/turing-machine:turing-machine?content=config
${PNFSIM_MOUNT_PATH}            /data/network-topology:network-topology/topology=topology-netconf/node=PNFDemo/yang-ext:mount?content=config
${GRA_PRELOAD_NETWORK}          /operations/GENERIC-RESOURCE-API:preload-network-topology-operation
${GRA_PRELOAD_VFMODULE}         /operations/GENERIC-RESOURCE-API:preload-vf-module-topology-operation
${GRA_SERVICE_TOPOLOGY}         /operations/GENERIC-RESOURCE-API:service-topology-operation
${GRA_NETWORK_TOPOLOGY}         /operations/GENERIC-RESOURCE-API:network-topology-operation
${GRA_VNF_TOPOLOGY}             /operations/GENERIC-RESOURCE-API:vnf-topology-operation
${GRA_VFMODULE_TOPOLOGY}        /operations/GENERIC-RESOURCE-API:vf-module-topology-operation
