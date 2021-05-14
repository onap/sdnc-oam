*** Variables ***

# SDNC Configuration
${ODL_USER}                              %{ODL_USER}
${ODL_PASSWORD}                          %{ODL_PASSWORD}
${REQUEST_DATA_PATH}                     %{REQUEST_DATA_PATH}
${SDNC_CONTAINER_NAME}                   %{SDNC_CONTAINER_NAME}
${SDNC_RESTCONF_URL}                     http://localhost:8282/restconf
${SDNC_HEALTHCHECK}                      /operations/SLI-API:healthcheck/
${SDNC_KEYSTORE_CONFIG_PATH}             /config/netconf-keystore:keystore
${SDNC_NETWORK_TOPOLOGY}                 /config/network-topology:network-topology
${SDNC_MOUNT_PATH}                       /config/network-topology:network-topology/topology/topology-netconf/node/PNFDemo
${PNFSIM_MOUNT_PATH}                     /config/network-topology:network-topology/topology/topology-netconf/node/PNFDemo/yang-ext:mount/turing-machine:turing-machine


