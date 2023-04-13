*** Settings ***
Documentation    devicemanager lifecycle via netconf only
...  Verify network element connection
...  Actions are triggered via server interface as used by ODLUX
...  Status verifcation is done by dataprovider interface and restconf mdsal
...  to detect asynchron connection status entries
Default Tags  dm-lifecycle  netconf  ssh

Library  ConnectLibrary
Library  SDNCBaseLibrary
Library  SDNCDataProvider
Library  SDNCRestconfLibrary
Library  ConnectApp
Library  FaultManagementApp
Library  FaultManagementAppBackend
Library  Collections
Library  DateTime
Library  utility

Suite Setup  global suite setup    &{GLOBAL_SUITE_SETUP_CONFIG}
Suite Teardown  global suite teardown



*** Variables ***
${DEVICE_TYPE}  DEFINE_IN_INIT
${DEVICE_NAME}  robot-${DEVICE_TYPE}-sim-lifecycle
${HOST}   ${NETWORK_FUNCTIONS}[${DEVICE_TYPE}][NETCONF_HOST]
${PORT}   ${NETWORK_FUNCTIONS}[${DEVICE_TYPE}][BASE_PORT]
${USERNAME}  ${NETWORK_FUNCTIONS}[${DEVICE_TYPE}][USER]
${PASSWORD}  ${NETWORK_FUNCTIONS}[${DEVICE_TYPE}][PASSWORD]
${HOST_NOK}  192.168.240.240
${PORT_NOK}  ${4711}
${USERNAME_NOK}  wrong-username
${PASSWORD_NOK}  wrong-password
${CORE_MODEL}  Unsupported
${UNDEFINED}  undefined
${DEVICE_TO_DELETE}  devices

# set log level https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html


*** Test Cases ***

Add network element connection
  [Documentation]  Add network-function to device manager
  ...              verify correct detection of specific device manager
  ...              verify correct entries in connection log
  [Tags]  smoke

  Set Test Variable  ${DEVICE_NAME_TEST}  ${DEVICE_NAME}-ok
  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  Log To Console  ${start_time}
  ConnectApp.Add network element connection    device_name=${DEVICE_NAME_TEST}    is_required=${True}
  ...  host=${HOST}    port=${PORT}    username=${USERNAME}    password=${PASSWORD}
  Run Keyword And Continue On Failure  ConnectApp.Should Be Equal connection status until time  ${DEVICE_NAME_TEST}  Connected
  SDNCRestconfLibrary.should_be_equal_connection_status_until_time  ${DEVICE_NAME_TEST}  connected  time_in_sec=${10}
  Run Keyword And Continue On Failure  ConnectApp.should_be_equal_network_element_connection_details  ${DEVICE_NAME_TEST}
                                                                     ...  node-id=${DEVICE_NAME_TEST}
                                                                     ...  is-required=${True}
                                                                     ...  status=Connected
                                                                     ...  host=${HOST}
                                                                     ...  port=${PORT}
                                                                     ...  device-type=${DEVICE_TYPE_GUI}
  # Check connection status log entries
  Sleep  1s  reason=insert time gap to avoid time constrains
  ${connection_status_list} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...   timestamp=>=${start_time}
  Log  ${connection_status_list}
  ${conn_status_list_stats} =  get_counts_from_list  ${connection_status_list}  status
  Log Dictionary  ${conn_status_list_stats}
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Connected  ${1}
  ...  msg=wrong connection log entries for Connected state
  Dictionary Should Contain Item  ${conn_status_list_stats}  Mounted  ${1}    msg=wrong connection log entries for Mounted state

Retrieve yang capabilities from network element
  [Documentation]  get yang capabilities from network element  and compare with reference file
  [Tags]  smoke  netconf  yang

  Set Test Variable  ${DEVICE_NAME_TEST}  ${DEVICE_NAME}-ok
  ${yang_capabilities} =  get_yang_capabilities_as_list  node_id=${DEVICE_NAME_TEST}
  Log  ${yang_capabilities}
  ${is_yang_correct} =  compare_yang_capability_list_to_file  ${yang_capabilities}  ${YANG_CAPABILITIES_FILE}
  Should be True  ${is_yang_correct}  msg=Yang capabilities are different from expected list

Remove network element connection
  [Documentation]  remove network element connection from device manager
  ...              verify if all ressources are removed
  ...              verify correct entries in connection log
  [Tags]  smoke

  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  Set Test Variable  ${DEVICE_NAME_TEST}  ${DEVICE_NAME}-ok
  ConnectApp.Remove network element connection  ${DEVICE_NAME_TEST}
  Run Keyword And Continue On Failure  ConnectApp.Should be equal connection status until time  ${DEVICE_NAME_TEST}  not existing
  SDNCRestconfLibrary.should_be_equal_connection_status_until_time  ${DEVICE_NAME_TEST}  not existing  time_in_sec=${10}

  # Check connection status log entries
  Sleep  6s  reason=insert time gap to avoid time constrains
  ${connection_status_list} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...   timestamp=>=${start_time}
  Log  ${connection_status_list}
  ${connection_status_list_debug} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
  Log  ${connection_status_list_debug}
  ${connection_status_list_debug_backend} =  FaultManagementAppBackend.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...  timestamp=>=${start_time}
  Log  ${connection_status_list_debug_backend}
  ${conn_status_list_stats} =  get_counts_from_list  ${connection_status_list}  status
  Log Dictionary  ${conn_status_list_stats}
  Dictionary Should Contain Item  ${conn_status_list_stats}  Unmounted  ${1}    msg=wrong connection log entries for Unmounted state

Add network element connection wrong port
  [Tags]  prio2
  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  Set Test Variable  ${DEVICE_NAME_TEST}  ${DEVICE_NAME}-port-nok
  ConnectApp.Add network element connection    device_name=${DEVICE_NAME_TEST}    is_required=${True}    host=${HOST}
  ...  port=${PORT_NOK}    username=${USERNAME}    password=${PASSWORD}
  Run Keyword And Continue On Failure  ConnectApp.Should Be Equal connection status until time  ${DEVICE_NAME_TEST}  Connecting
  SDNCRestconfLibrary.should_be_equal_connection_status_until_time  ${DEVICE_NAME_TEST}  connecting  time_in_sec=${10}
  Run Keyword And Continue On Failure  ConnectApp.should_be_equal_network_element_connection_details  ${DEVICE_NAME_TEST}
                                                                     ...  node-id=${DEVICE_NAME_TEST}
                                                                     ...  is-required=${True}
                                                                     ...  status=Connecting
                                                                     ...  host=${HOST}
                                                                     ...  port=${PORT_NOK}
  # Check connection status log entries
  Sleep  1s  reason=insert time gap to avoid time constrains
  ${connection_status_list} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...   timestamp=>=${start_time}
  Log  ${connection_status_list}
  ${conn_status_list_stats} =  get_counts_from_list  ${connection_status_list}  status
  Log Dictionary  ${conn_status_list_stats}
  ${connection_status_list_debug} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
  Log  ${connection_status_list_debug}
  ${connection_status_list_debug_backend} =  FaultManagementAppBackend.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...  timestamp=>=${start_time}
  Log  ${connection_status_list_debug_backend}
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Mounted  ${1}  msg=wrong connection log entries for Mounted state
  Run Keyword And Continue On Failure  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Connected
  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Unmounted

Remove network element connection wrong port
  [Tags]  prio2
  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  Set Test Variable  ${DEVICE_NAME_TEST}  ${DEVICE_NAME}-port-nok
  ConnectApp.Remove network element connection  ${DEVICE_NAME_TEST}
  Run Keyword And Continue On Failure  ConnectApp.Should be equal connection status until time  ${DEVICE_NAME_TEST}  not existing
  SDNCRestconfLibrary.should_be_equal_connection_status_until_time  ${DEVICE_NAME_TEST}  not existing  time_in_sec=${10}

  # Check connection status log entries
  Sleep  1s  reason=insert time gap to avoid time constrains
  ${connection_status_list} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...   timestamp=>=${start_time}
  Log  ${connection_status_list}
  ${connection_status_list_debug} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
  Log  ${connection_status_list_debug}
  ${connection_status_list_debug_backend} =  FaultManagementAppBackend.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...  timestamp=>=${start_time}
  Log  ${connection_status_list_debug_backend}
  ${conn_status_list_stats} =  get_counts_from_list  ${connection_status_list}  status
  Log Dictionary  ${conn_status_list_stats}
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Unmounted  ${1}  msg=wrong connection log entries for Unmounted state
  Run Keyword And Continue On Failure  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Connected
  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Mounted

Add network element connection wrong ip
  [Tags]  prio2
  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  Set Test Variable  ${DEVICE_NAME_TEST}  ${DEVICE_NAME}-ip-nok
  ConnectApp.Add network element connection    device_name=${DEVICE_NAME_TEST}    is_required=${True}    host=${HOST_NOK}
  ...  port=${PORT}    username=${USERNAME}    password=${PASSWORD}
  Run Keyword And Continue On Failure  ConnectApp.Should Be Equal connection status until time  ${DEVICE_NAME_TEST}  Connecting
  Run Keyword And Continue On Failure  SDNCRestconfLibrary.should_be_equal_connection_status_until_time  ${DEVICE_NAME_TEST}  connecting  time_in_sec=${10}
  Run Keyword And Continue On Failure  ConnectApp.should_be_equal_network_element_connection_details  ${DEVICE_NAME_TEST}
                                                                     ...  node-id=${DEVICE_NAME_TEST}
                                                                     ...  is-required=${True}
                                                                     ...  status=Connecting
                                                                     ...  host=${HOST_NOK}
                                                                     ...  port=${PORT}
  # Check connection status log entries
  Sleep  1s  reason=insert time gap to avoid time constrains
  ${connection_status_list} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...   timestamp=>=${start_time}
  Log  ${connection_status_list}
  ${connection_status_list_debug} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
  Log  ${connection_status_list_debug}
  ${connection_status_list_debug_backend} =  FaultManagementAppBackend.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...  timestamp=>=${start_time}
  Log  ${connection_status_list_debug_backend}
  ${conn_status_list_stats} =  get_counts_from_list  ${connection_status_list}  status
  Log Dictionary  ${conn_status_list_stats}
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Mounted  ${1}  msg=wrong connection log entries for Mounted state
  Run Keyword And Continue On Failure  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Connected
  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Unmounted

Remove network element connection wrong ip
  [Tags]  prio2
  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  Set Test Variable  ${DEVICE_NAME_TEST}  ${DEVICE_NAME}-ip-nok
  ConnectApp.Remove network element connection  ${DEVICE_NAME_TEST}
  Run Keyword And Continue On Failure  ConnectApp.Should be equal connection status until time  ${DEVICE_NAME_TEST}  not existing
  Run Keyword And Continue On Failure  SDNCRestconfLibrary.should_be_equal_connection_status_until_time  ${DEVICE_NAME_TEST}  not existing  time_in_sec=${10}

  # Check connection status log entries
  Sleep  1s  reason=insert time gap to avoid time constrains
  ${connection_status_list} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...   timestamp=>=${start_time}
  Log  ${connection_status_list}
  ${connection_status_list_debug} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
  Log  ${connection_status_list_debug}
  ${connection_status_list_debug_backend} =  FaultManagementAppBackend.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...  timestamp=>=${start_time}
  Log  ${connection_status_list_debug_backend}
  ${conn_status_list_stats} =  get_counts_from_list  ${connection_status_list}  status
  Log Dictionary  ${conn_status_list_stats}
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Unmounted  ${1}  msg=wrong connection log entries for Unmounted state
  Run Keyword And Continue On Failure  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Connected
  Run Keyword And Continue On Failure  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Mounted

Add network element connection and change is required to false
  [Tags]  prio2
  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  Set Test Variable  ${DEVICE_NAME_TEST}  ${DEVICE_NAME}-required
  ConnectApp.Add network element connection    device_name=${DEVICE_NAME_TEST}    is_required=${True}    host=${HOST}
  ...  port=${PORT}    username=${USERNAME}    password=${PASSWORD}
  Run Keyword And Continue On Failure  ConnectApp.Should Be Equal connection status until time  ${DEVICE_NAME_TEST}  Connected
  SDNCRestconfLibrary.should_be_equal_connection_status_until_time  ${DEVICE_NAME_TEST}  connected  time_in_sec=${10}
  Run Keyword And Continue On Failure  ConnectApp.should_be_equal_network_element_connection_details  ${DEVICE_NAME_TEST}
                                                                     ...  node-id=${DEVICE_NAME_TEST}
                                                                     ...  is-required=${True}

  ConnectApp.edit network element connection    ${DEVICE_NAME_TEST}    ${False}
  Run Keyword And Continue On Failure  ConnectApp.should_be_equal_network_element_connection_details  ${DEVICE_NAME_TEST}
                                                                     ...  node-id=${DEVICE_NAME_TEST}
                                                                     ...  is-required=${False}
  # Check connection status log entries
  Sleep  1s  reason=insert time gap to avoid time constrains
  ${connection_status_list} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...   timestamp=>=${start_time}
  Log  ${connection_status_list}
  ${connection_status_list_debug} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
  Log  ${connection_status_list_debug}
  ${connection_status_list_debug_backend} =  FaultManagementAppBackend.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...  timestamp=>=${start_time}
  Log  ${connection_status_list_debug_backend}
  ${conn_status_list_stats} =  get_counts_from_list  ${connection_status_list}  status
  Log Dictionary  ${conn_status_list_stats}
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Connected  ${1}  msg=wrong connection log entries for Connected state
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Mounted  ${1}    msg=wrong connection log entries for Mounted state

Edit network element connection: is required to true
  [Tags]  prio2
  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  Set Test Variable  ${DEVICE_NAME_TEST}  ${DEVICE_NAME}-required
  ConnectApp.edit network element connection    ${DEVICE_NAME_TEST}    ${True}
  Run Keyword And Continue On Failure  ConnectApp.should_be_equal_network_element_connection_details  ${DEVICE_NAME_TEST}
                                                                     ...  node-id=${DEVICE_NAME_TEST}
                                                                     ...  is-required=${True}
  # Check connection status log entries
  Sleep  1s  reason=insert time gap to avoid time constrains
  ${connection_status_list} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...   timestamp=>=${start_time}
  Log  ${connection_status_list}
  ${connection_status_list_debug} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
  Log  ${connection_status_list_debug}
  ${connection_status_list_debug_backend} =  FaultManagementAppBackend.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...  timestamp=>=${start_time}
  Log  ${connection_status_list_debug_backend}
  ${conn_status_list_stats} =  get_counts_from_list  ${connection_status_list}  status
  Log Dictionary  ${conn_status_list_stats}
  Run Keyword And Continue On Failure  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Connected
  Run Keyword And Continue On Failure  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Mounted
  Run Keyword And Continue On Failure  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Unmounted
  #Dictionary Should Not Contain Key  ${conn_status_list_stats}  Connecting

Unmount network element
  [Tags]  prio2
  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  Set Test Variable  ${DEVICE_NAME_TEST}  ${DEVICE_NAME}-required
  ConnectApp.unmount_network_element  ${DEVICE_NAME_TEST}
  Run Keyword And Continue On Failure  ConnectApp.Should Be Equal connection status until time  ${DEVICE_NAME_TEST}  Disconnected
  Run Keyword And Continue On Failure  SDNCRestconfLibrary.should_be_equal_connection_status_until_time  ${DEVICE_NAME_TEST}  not existing  time_in_sec=${10}

  # Check connection status log entries
  Sleep  1s  reason=insert time gap to avoid time constrains
  ${connection_status_list} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...   timestamp=>=${start_time}
  Log  ${connection_status_list}
  ${connection_status_list_debug} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
  Log  ${connection_status_list_debug}
  ${connection_status_list_debug_backend} =  FaultManagementAppBackend.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...  timestamp=>=${start_time}
  Log  ${connection_status_list_debug_backend}
  ${conn_status_list_stats} =  get_counts_from_list  ${connection_status_list}  status
  Log Dictionary  ${conn_status_list_stats}
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Unmounted  ${1}    msg=wrong connection log entries for Unmounted state
  Run Keyword And Continue On Failure  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Connected
  Run Keyword And Continue On Failure  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Mounted
  #Dictionary Should Not Contain Key  ${conn_status_list_stats}  Connecting


Mount network element
  [Tags]  prio2
  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  Set Test Variable  ${DEVICE_NAME_TEST}  ${DEVICE_NAME}-required
  ConnectApp.mount_network_element  ${DEVICE_NAME_TEST}
  Run Keyword And Continue On Failure  ConnectApp.Should Be Equal connection status until time  ${DEVICE_NAME_TEST}  Connected
  Run Keyword And Continue On Failure  SDNCRestconfLibrary.should_be_equal_connection_status_until_time  ${DEVICE_NAME_TEST}  connected  time_in_sec=${10}

  # Check connection status log entries
  Sleep  1s  reason=insert time gap to avoid time constrains
  ${connection_status_list} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...   timestamp=>=${start_time}
  Log  ${connection_status_list}
  ${connection_status_list_debug} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
  Log  ${connection_status_list_debug}
  ${connection_status_list_debug_backend} =  FaultManagementAppBackend.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...  timestamp=>=${start_time}
  Log  ${connection_status_list_debug_backend}
  ${conn_status_list_stats} =  get_counts_from_list  ${connection_status_list}  status
  Log Dictionary  ${conn_status_list_stats}
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Connected  ${1}  msg=wrong connection log entries for Connected state
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Mounted  ${1}    msg=wrong connection log entries for Mounted state

Mount Nts Network Function with VALID TLS Key ID
  IF    'DOCKER_TLS_PORT' in ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']}
       Run Keyword And Continue On Failure  Add Network Element Connection     device_name=${DEVICE_NAME}_sim_key_0
                                  ...  is_required=${True}
                                  ...  host=${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['IP']}
                                  ...  port=${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['DOCKER_TLS_PORT']}
                                  ...  username=${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['USER']}
                                  ...  tls_key=ODL_private_key_0
                                  ...  check_connection_status=Connected
                                  ...  time_to_wait=60
       ConnectApp.remove_network_element_connection    ${DEVICE_NAME}_sim_key_0
  END

Remove network element connection
  [Tags]  prio2
  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  Set Test Variable  ${DEVICE_NAME_TEST}  ${DEVICE_NAME}-required
  ConnectApp.remove network element connection    ${DEVICE_NAME_TEST}
  Run Keyword And Continue On Failure  ConnectApp.Should Be Equal connection status until time  ${DEVICE_NAME_TEST}  not existing
  Run Keyword And Continue On Failure  SDNCRestconfLibrary.should_be_equal_connection_status_until_time  ${DEVICE_NAME_TEST}  not existing  time_in_sec=${10}

  # Check connection status log entries
  Sleep  5s  reason=insert time gap to avoid time constrains
  ${connection_status_list} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...   timestamp=>=${start_time}
  Log  ${connection_status_list}
  ${connection_status_list_debug} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
  Log  ${connection_status_list_debug}
  ${connection_status_list_debug_backend} =  FaultManagementAppBackend.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...  timestamp=>=${start_time}
  Log  ${connection_status_list_debug_backend}
  ${conn_status_list_stats} =  get_counts_from_list  ${connection_status_list}  status
  Log Dictionary  ${conn_status_list_stats}
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Unmounted  ${1}    msg=wrong connection log entries for Unmounted state
  Run Keyword And Continue On Failure  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Connected
  Run Keyword And Continue On Failure  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Mounted
  #Dictionary Should Not Contain Key  ${conn_status_list_stats}  Connecting

Remove unmounted network element connection
  [Tags]  prio2
  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  Set Test Variable  ${DEVICE_NAME_TEST}  ${DEVICE_NAME}-required-true
  ConnectApp.Add network element connection    device_name=${DEVICE_NAME_TEST}    is_required=${True}    host=${HOST}
  ...  port=${PORT}    username=${USERNAME}    password=${PASSWORD}
  Run Keyword And Continue On Failure  ConnectApp.Should Be Equal connection status until time  ${DEVICE_NAME_TEST}  Connected
  Run Keyword And Continue On Failure  SDNCRestconfLibrary.should_be_equal_connection_status_until_time  ${DEVICE_NAME_TEST}  connected  time_in_sec=${10}

  ConnectApp.unmount_network_element    ${DEVICE_NAME_TEST}
  Run Keyword And Continue On Failure  ConnectApp.Should Be Equal connection status until time  ${DEVICE_NAME_TEST}  Disconnected
  Run Keyword And Continue On Failure  SDNCRestconfLibrary.should_be_equal_connection_status_until_time  ${DEVICE_NAME_TEST}  not existing  time_in_sec=${10}

  ConnectApp.remove_network_element_connection    ${DEVICE_NAME_TEST}
  Run Keyword And Continue On Failure  ConnectApp.Should Be Equal connection status until time  ${DEVICE_NAME_TEST}  not existing

  # Check connection status log entries
  Sleep  1s  reason=insert time gap to avoid time constrains
  ${connection_status_list} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...   timestamp=>=${start_time}
  Log  ${connection_status_list}
  ${connection_status_list_debug} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
  Log  ${connection_status_list_debug}
  ${connection_status_list_debug_backend} =  FaultManagementAppBackend.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...  timestamp=>=${start_time}
  Log  ${connection_status_list_debug_backend}
  ${conn_status_list_stats} =  get_counts_from_list  ${connection_status_list}  status
  Log Dictionary  ${conn_status_list_stats}
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Mounted  ${1}    msg=wrong connection log entries for Mounted state
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Connected  ${1}    msg=wrong connection log entries for Connected state
  Run Keyword And Continue On Failure  Dictionary Should Contain Key  ${conn_status_list_stats}  Unmounted  msg=no connection log entries for Unmounted state
  ConnectApp.Remove Network Element Connection    ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}

Add network element connection and remount
  [Tags]  smoke
  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  Set Test Variable  ${DEVICE_NAME_TEST}  ${DEVICE_NAME}-remount
  Log To Console  ${start_time}
  ConnectApp.Add network element connection    device_name=${DEVICE_NAME_TEST}    is_required=${True}
  ...  host=${HOST}    port=${PORT}    username=${USERNAME}    password=${PASSWORD}
  Run Keyword And Continue On Failure  ConnectApp.Should Be Equal connection status until time  ${DEVICE_NAME_TEST}  Connected
  SDNCRestconfLibrary.should_be_equal_connection_status_until_time  ${DEVICE_NAME_TEST}  connected  time_in_sec=${10}
  Run Keyword And Continue On Failure  ConnectApp.should_be_equal_network_element_connection_details  ${DEVICE_NAME_TEST}
                                                                     ...  node-id=${DEVICE_NAME_TEST}
                                                                     ...  is-required=${True}
                                                                     ...  status=Connected
                                                                     ...  host=${HOST}
                                                                     ...  port=${PORT}
                                                                     ...  device-type=${DEVICE_TYPE_GUI}
  # Check connection status log entries
  Sleep  1s  reason=insert time gap to avoid time constrains
  ${connection_status_list} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...   timestamp=>=${start_time}
  Log  ${connection_status_list}
  ${conn_status_list_stats} =  get_counts_from_list  ${connection_status_list}  status
  Log Dictionary  ${conn_status_list_stats}
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Connected  ${1}  msg=wrong connection log entries for Connected state
  Dictionary Should Contain Item  ${conn_status_list_stats}  Mounted  ${1}    msg=wrong connection log entries for Mounted state

  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  # perform a mount on a alredy connected device
  ConnectApp.mount_network_element  ${DEVICE_NAME_TEST}
  Run Keyword And Continue On Failure  ConnectApp.Should Be Equal connection status until time  ${DEVICE_NAME_TEST}  Connected
  Run Keyword And Continue On Failure  SDNCRestconfLibrary.should_be_equal_connection_status_until_time  ${DEVICE_NAME_TEST}  connected  time_in_sec=${10}

  # Check connection status log entries
  Sleep  1s  reason=insert time gap to avoid time constrains
  ${connection_status_list} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...   timestamp=>=${start_time}
  Log  ${connection_status_list}
  ${connection_status_list_debug} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
  Log  ${connection_status_list_debug}
  ${connection_status_list_debug_backend} =  FaultManagementAppBackend.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...  timestamp=>=${start_time}
  Log  ${connection_status_list_debug_backend}
  ${conn_status_list_stats} =  get_counts_from_list  ${connection_status_list}  status
  Log Dictionary  ${conn_status_list_stats}
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Connected  ${1}  msg=wrong connection log entries for Connected state
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Mounted  ${1}    msg=wrong connection log entries for Mounted state

Remove remounted network element connection
  [Tags]  smoke
  Sleep  3s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  3s  reason=insert time delay to account for time differences of container and host
  Set Test Variable  ${DEVICE_NAME_TEST}  ${DEVICE_NAME}-remount
  ConnectApp.Remove network element connection  ${DEVICE_NAME_TEST}
  Run Keyword And Continue On Failure  ConnectApp.Should be equal connection status until time  ${DEVICE_NAME_TEST}  not existing
  Run Keyword And Continue On Failure  SDNCRestconfLibrary.should_be_equal_connection_status_until_time  ${DEVICE_NAME_TEST}  not existing  time_in_sec=${10}

  # Check connection status log entries
  Sleep  1s  reason=insert time gap to avoid time constrains
  ${connection_status_list} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...   timestamp=>=${start_time}
  Log  ${connection_status_list}
  ${connection_status_list_debug} =  FaultManagementApp.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
  Log  ${connection_status_list_debug}
  ${connection_status_list_debug_backend} =  FaultManagementAppBackend.get_connection_log_list  node-id=${DEVICE_NAME_TEST}
                                                                     ...  timestamp=>=${start_time}
  Log  ${connection_status_list_debug_backend}
  ${conn_status_list_stats} =  get_counts_from_list  ${connection_status_list}  status
  Log Dictionary  ${conn_status_list_stats}
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${conn_status_list_stats}  Unmounted  ${1}  msg=wrong connection log entries for Unmounted state
  Run Keyword And Continue On Failure  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Connected
  Run Keyword And Continue On Failure  Dictionary Should Not Contain Key  ${conn_status_list_stats}  Mounted