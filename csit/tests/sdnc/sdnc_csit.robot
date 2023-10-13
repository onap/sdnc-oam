*** Settings ***

Documentation     SDNC, Netconf-Pnp-Simulator E2E Test Case Scenarios

Library           RequestsLibrary
Resource          ./resources/sdnc-keywords.robot


*** Test Cases ***
Check SDNC health
    [Tags]      SDNC-healthcheck
    [Documentation]    Sending healthcheck
    Send Empty Post Request And Validate Response  ${SDNC_HEALTHCHECK}   200

Check SDNC Keystore For PNF Simulator Certificates
    [Tags]      SDNC-PNFSIM-CERT-DEPLOYMENT
    [Documentation]    Checking Keystore after SDNC installation
    Send Get Request And Validate Response Sdnc  ${SDNC_KEYSTORE_CONFIG_PATH}  200

# 2 tests below are Commented out because of outdated PNF Sim certs .. see SDNC-1830
# Check SDNC NETCONF/TLS Connection to PNF Simulator
#    [Tags]      SDNC-PNFSIM-TLS-CONNECTION-CHECK
#    [Documentation]    Checking NETCONF/TLS connection to PNF Simulator
#    Send Get Request And Validate TLS Connection Response  ${SDNC_MOUNT_PATH}  200
#
#Check Dropping NETCONF/TLS Connection
#    [Tags]      SDNC-PNFSIM-TLS-DISCONNECT-CHECK
#    [Documentation]    Checking PNF Simulator Mount Delete from SDNC
#   Send Delete Request And Validate PNF Mount Deleted  ${SDNC_MOUNT_PATH}  204

Load network preload data
    [Tags]     SDNC-GRA-PRELOAD-NETWORK
    [Documentation]    Loading network preload data
    Send Post File And Validate Response    ${GRA_PRELOAD_NETWORK}    ${GRA_DATA_DIRECTORY}/preload-network.json     200
Load vf-module preload data
    [Tags]     SDNC-GRA-PRELOAD-VF-MODULE
    [Documentation]    Loading vf-module preload data
    Send Post File And Validate Response    ${GRA_PRELOAD_VFMODULE}   ${GRA_DATA_DIRECTORY}/preload-vf-module.json   200
Check GRA service assign
    [Tags]     SDNC-GRA-SERVICE-ASSIGN
    [Documentation]    Testing GRA service assign
    Send Post File And Validate Response    ${GRA_SERVICE_TOPOLOGY}   ${GRA_DATA_DIRECTORY}/svc-topology-assign.json   200
Check GRA network assign
    [Tags]     SDNC-GRA-NETWORK-ASSIGN
    [Documentation]    Testing GRA network assign
    Send Post File And Validate Response    ${GRA_NETWORK_TOPOLOGY}   ${GRA_DATA_DIRECTORY}/network-topology-assign.json   200
Check GRA vnf assign
    [Tags]     SDNC-GRA-VNF-ASSIGN
    [Documentation]    Testing GRA vnf assign
    Send Post File And Validate Response    ${GRA_VNF_TOPOLOGY}   ${GRA_DATA_DIRECTORY}/vnf-topology-assign.json   200
Check GRA vf-module assign
    [Tags]     SDNC-GRA-VF-MODULE-ASSIGN
    [Documentation]    Testing GRA vf-module assign
    Send Post File And Validate Response    ${GRA_VFMODULE_TOPOLOGY}   ${GRA_DATA_DIRECTORY}/vf-module-topology-assign.json   200
Check GRA vf-module unassign
    [Tags]     SDNC-GRA-VF-MODULE-UNASSIGN
    [Documentation]    Testing GRA vf-module unassign
    Send Post File And Validate Response    ${GRA_VFMODULE_TOPOLOGY}   ${GRA_DATA_DIRECTORY}/vf-module-topology-unassign.json   200
Check GRA vnf unassign
    [Tags]     SDNC-GRA-VNF-UNASSIGN
    [Documentation]    Testing GRA vnf unassign
    Send Post File And Validate Response    ${GRA_VNF_TOPOLOGY}   ${GRA_DATA_DIRECTORY}/vnf-topology-unassign.json   200
Check GRA network unassign
    [Tags]     SDNC-GRA-NETWORK-UNASSIGN
    [Documentation]    Testing GRA network unassign
    Send Post File And Validate Response    ${GRA_NETWORK_TOPOLOGY}   ${GRA_DATA_DIRECTORY}/network-topology-unassign.json   200
Check GRA service delete
    [Tags]     SDNC-GRA-SERVICE-DELETE
    [Documentation]    Testing GRA service delete
    Send Post File And Validate Response    ${GRA_SERVICE_TOPOLOGY}   ${GRA_DATA_DIRECTORY}/svc-topology-delete.json   200



