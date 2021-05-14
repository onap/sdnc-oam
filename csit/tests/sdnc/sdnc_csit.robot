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


Check SDNC NETCONF/TLS Connection to PNF Simulator
    [Tags]      SDNC-PNFSIM-TLS-CONNECTION-CHECK
   [Documentation]    Checking NETCONF/TLS connection to PNF Simulator
    Send Get Request And Validate TLS Connection Response  ${SDNC_MOUNT_PATH}  200

Check Dropping NETCONF/TLS Connection
    [Tags]      SDNC-PNFSIM-TLS-DISCONNECT-CHECK
    [Documentation]    Checking PNF Simulator Mount Delete from SDNC
   Send Delete Request And Validate PNF Mount Deleted  ${SDNC_MOUNT_PATH}  200

