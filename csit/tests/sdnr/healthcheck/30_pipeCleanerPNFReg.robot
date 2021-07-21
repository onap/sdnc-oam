*** Settings ***
Documentation     In a new deployment of sdnc, ves collector and message router 
...  the first pnf registration request fails.
...  Therefore some requets are send to ensure proper working of the use case
...  VES endpoint details test environemnt variable file <environment>.py
...  as dictionary NETWORK_FUNCTIONS = {}, VESCOLLECTOR ={}


Library  ConnectLibrary
Library  SDNCBaseLibrary
Library  NTSimManagerNG
Library  ConnectApp


Suite Setup  global suite setup    &{GLOBAL_SUITE_SETUP_CONFIG}
Suite Teardown  global suite teardown


*** Variables ***
${DEVICE_TYPE}  O_RAN_FH
${CHECK_CONNECTION_STATUS}  Connected
${SIM_COUNT}  1
${PNF_REGISTRATION_TIMEOUT}  60s
${FAULT_DELAY}  5
${TIME_PERIOD_SEND_NOTIF}  30s

*** Test Cases ***
Add Network Function O-RAN-FH in connectApp
  [Tags]  healthcheck  sim
  [Documentation]  add nf as network element connection and verifies connection status

  ConnectApp.add_network_element_connection_from_dict  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']}  check_connection_status=${CHECK_CONNECTION_STATUS}

Send pnf registration request to VES collector
  [Tags]  healthcheck  sim
  [Documentation]  set details for VES endpoint details and 
  ...              send pnf registration requests

  NTSimManagerNG.set_ves_endpoint_details_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}
  ...  ves-endpoint-ip=${VESCOLLECTOR}[IP]
  ...  ves-endpoint-port=${VESCOLLECTOR}[PORT]
  ...  ves-endpoint-auth-method=${VESCOLLECTOR}[AUTHMETHOD]
  ...  ves-endpoint-username=${VESCOLLECTOR}[USERNAME]
  ...  ves-endpoint-password=${VESCOLLECTOR}[PASSWORD]
  NTSimManagerNG.set_ves_config_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}
  ...  pnf-registration=${True}

Send VES notifications
  [Tags]  healthcheck  sim
  [Documentation]  send some notifications for VES messages
  NTSimManagerNG.set_ves_config_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  faults-enabled=${True}
  NTSimManagerNG.set_fault_delay_list_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  delay-period=${FAULT_DELAY}
  Log  Send notification every ${FAULT_DELAY} sec for ${TIME_PERIOD_SEND_NOTIF}  level=INFO  html=False  console=True  repr=False
  Sleep  ${TIME_PERIOD_SEND_NOTIF}
  NTSimManagerNG.set_fault_delay_list_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  delay-period=${0}
  NTSimManagerNG.set_ves_config_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  faults-enabled=${False}

Remove mounted devices
  [Documentation]  cleanup all mounted devices
  [Tags]  healthcheck  sim
  NTSimManagerNG.set_ves_config_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}
  ...  pnf-registration=${False}
  ConnectApp.remove_network_element_connection_filtered  validate=${True}  node-id=.*
