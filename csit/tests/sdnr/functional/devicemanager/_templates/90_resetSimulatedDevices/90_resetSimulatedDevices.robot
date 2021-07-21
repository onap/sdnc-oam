*** Settings ***
Documentation     Set number of simulated devices of all device types
...  NTS manager information are stored in test environemnt variable file <environment>
...  as dictionary NTS_MANAGER = {}
...  change number devices on command line with  --variable  SIM_COUNT:10  --variable  DEVICE_TYPE:ORAN

Library  ConnectLibrary
Library  SDNCBaseLibrary
Library  NTSimManagerNG
Library  ConnectApp

Suite Setup  global_suite_setup
Suite Teardown  global suite teardown


*** Variables ***
${DEVICE_TYPE}  DEFINE_IN_INIT
${SIM_COUNT}  0


*** Test Cases ***
Reset simulated devices
  [Tags]  nts-manager  bringup
  [Documentation]  scales number of simulated devices per device type
  remove network element connection filtered  node-id=*
