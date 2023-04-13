*** Settings ***
Documentation     Set VES collector endpoint details in NTS manager
...  VES endpooint Details and NTS manager information are stored in test environemnt variable file <environment>
...  as dictionary NETWORK_FUNCTIONS = {}, VESCOLLECTOR ={}
...  change number devices on command line with   --variable  DEVICE_TYPE:ORAN
...

Library  ConnectLibrary
Library  String
Library  SDNCBaseLibrary
Library  SDNCRestconfLibrary
Library  NTSimManagerNG
Library  SDNCDataProvider
Library  ConnectApp

Suite Setup  global suite setup    &{GLOBAL_SUITE_SETUP_CONFIG}
Suite Teardown  global suite teardown


*** Variables ***
${DEVICE_TYPE}  DEFINE_IN_INIT
${SIM_COUNT}  1
${CORE_MODEL}  DEFINE_IN_INIT
${DEVICE_TYPE_GUI}  DEFINE_IN_INIT
${PNF_REGISTRATION_TIMEOUT}  180


*** Test Cases ***
Setup NTS function
  [Tags]  nts  bringup
  [Documentation]  configure NTS manager to support restconf registration
  Add Network Element Connection   device_name=${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}    is_required=${True}
  ...  host=${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['IP']}     port=${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['PORT']}
  ...  username=${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['USER']}    password=${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['PASSWORD']}
  ...  check_connection_status=Connected
  SDNCRestconfLibrary.Should Be Equal Connection Status Until Time    ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}    Connected

Start pnf ves registration from NTS function
  [Tags]  nts  bringup
  [Documentation]  scales number of simulated devices per device type to '0'
  ...              set details for VES endpoint
  ...              scales number of simulated devices per device type
  Stop Network Function Feature    ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}    ves-pnf-registration  # stopping feature not necessary
  NTSimManagerNG.set_ves_endpoint_details_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}
  ...  ves-endpoint-protocol=${VESCOLLECTOR}[SCHEME]
  ...  ves-endpoint-ip=${VESCOLLECTOR}[IP]
  ...  ves-endpoint-port=${VESCOLLECTOR}[PORT]
  ...  ves-endpoint-auth-method=${VESCOLLECTOR}[AUTHMETHOD]
  ...  ves-endpoint-username=${VESCOLLECTOR}[USERNAME]
  ...  ves-endpoint-password=${VESCOLLECTOR}[PASSWORD]
  Start Network Function Feature    ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}    ves-pnf-registration
  NTSimManagerNG.set_ves_config_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}
  ...  pnf-registration=${True}
  sleep  10s  reason=Wait before start network function
#  Log  console=True  message=Wait some time ${PNF_REGISTRATION_TIMEOUT} till request sent by NTSim
#  ConnectApp.should_be_equal_connection_status_until_time  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  Connected  ${180}


Verify connection status SSH
  [Tags]  pnfregistration  dm-lifecycle  SSH
  sleep  5s  reason=Wait for processing of simulated device
  @{pnf_list}=  NTSimManagerNG.get_simulated_pnfs_nf  ${DEVICE_TYPE}  protocol=SSH
  ${length} = 	Get Length 	${pnf_list}
  Should Not Be Equal As Integers 	${length} 	0  msg=No network functions created

  Log to console  ${pnf_list}
  FOR    ${device}    IN    @{pnf_list}
    ${node_id}=  set variable  ${device["node-id"]}
    ${port}=  set variable  ${device["port"]}
    Log  console=True  message=Verify connection status: ${node_id}
    Run Keyword And Continue On Failure  ConnectApp.Should Be Equal connection status until time
                                                                     ...  ${node_id}  Connected   ${PNF_REGISTRATION_TIMEOUT}
    SDNCRestconfLibrary.Should Be Equal Connection Status Until Time    ${node_id}  connected  ${5}
    ConnectApp.should_be_equal_network_element_connection_details  ${node_id}
                                                                     ...  node-id=${node_id}
                                                                     ...  is-required=${False}
                                                                     ...  status=Connected
                                                                     ...  port=${port}
                                                                     ...  device-type=${DEVICE_TYPE_GUI}
  END

Verify connection status TLS
  [Tags]  pnfregistration  dm-lifecycle  TLS
  @{pnf_list}=  NTSimManagerNG.get_simulated_pnfs_nf  ${DEVICE_TYPE}  protocol=TLS
  Log to console  ${pnf_list}
  ${length} = 	Get Length 	${pnf_list}
  Should Not Be Equal As Integers 	${length} 	0  msg=No network functions created

  FOR    ${device}    IN    @{pnf_list}
    ${node_id}=  set variable  ${device["node-id"]}
    ${port}=  set variable  ${device["port"]}
    Log  console=True  message=Verify connection status: ${node_id}
    Run Keyword And Continue On Failure  ConnectApp.Should Be Equal connection status until time
                                                                     ...  ${node_id}  Connected   ${PNF_REGISTRATION_TIMEOUT}
    SDNCRestconfLibrary.Should Be Equal Connection Status Until Time    ${node_id}  connected  ${5}
    ConnectApp.should_be_equal_network_element_connection_details  ${node_id}
                                                                     ...  node-id=${node_id}
                                                                     ...  is-required=${False}
                                                                     ...  status=Connected
                                                                     ...  port=${port}
                                                                     ...  device-type=${DEVICE_TYPE_GUI}
  END

Remove all networkelement connections
  [Documentation]  Delete all network element connections, should not fail if the connection is not there
  [Tags]  restconf  dm-lifecycle
  Stop Network Function Feature    ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}    ves-pnf-registration
  @{pnf_list}=  NTSimManagerNG.get_simulated_pnfs_nf  ${DEVICE_TYPE}
  FOR    ${device}    IN    @{pnf_list}
    ${node_id}=  set variable  ${device["node-id"]}
    Run Keyword And Ignore Error  ConnectApp.remove network element connection filtered  node-id=${node_id}
  END
  NTSimManagerNG.set_ves_config_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}
  ...  pnf-registration=${False}
  ConnectApp.Remove Network Element Connection    ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}

