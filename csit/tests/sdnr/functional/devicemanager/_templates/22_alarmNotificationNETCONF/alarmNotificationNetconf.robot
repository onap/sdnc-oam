*** Settings ***
Documentation     Connects NTSim of specific device type
...  NTSim information are stored in test environment variable file <environment>
...  as dictionary NETWORK_FUNCTIONS = {}
...  change device type on command line with e.g. --variable  DEVICE_TYPE:O_RAN_FH
...  Enable alarms by setting fault-notification-delay-period and validate the alarms raised by NTS 
...  received by SDNR via netconf
Default Tags  fm  ves

Library  ConnectLibrary
Library  SDNCBaseLibrary
Library  SDNCRestconfLibrary
Library  ConnectApp
Library  NTSimManagerNG
Library  FaultManagementApp
Library  FaultManagementAppBackend
Library  utility
Library  DateTime
Library  Collections

Suite Setup  global suite setup    &{GLOBAL_SUITE_SETUP_CONFIG}
Suite Teardown  global suite teardown


*** Variables ***
${DEVICE_TYPE}  DEFINE_IN_INIT
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
${FAULT_DELAY}  10
${TIME_PERIOD_SEND_NOTIF}  22s
&{ALARM_SEVERITY_DEFAULT}  Critical=${0}  Major=${0}  Minor=${0}  Warning=${0}  NonAlarmed=${0}


*** Test Cases ***
Setup NTS function
  [Tags]  nts  bringup
  [Documentation]  configure NTS manager to support restconf registration
  Add Network Element Connection   device_name=${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  is_required=${True}
  ...  host=${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['IP']}     port=${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['PORT']}
  ...  username=${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['USER']}    password=${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['PASSWORD']}
  ...  check_connection_status=Connected
  SDNCRestconfLibrary.Should Be Equal Connection Status Until Time    ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}    Connected

Set alarm notification
  [Tags]  smoke
  NTSimManagerNG.clear_alarm_count  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}
  NTSimManagerNG.Set Netconf Config Nf    ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  faults-enabled=${True}
  ${vesAlarmGenerated} =  NTSimManagerNG.Get Alarm Count  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}
  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  Set Global Variable  ${start_time}
  ${current_problem_list}=  FaultManagementApp.Get Current Problem List
  Log  ${current_problem_list}
  ${alarm_status_start} =  FaultManagementApp.get_alarm_status
  Set Global Variable  ${alarm_status_start}
  NTSimManagerNG.set_fault_delay_list_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  delay-period=${fault_delay}

  Log  Send notification every ${FAULT_DELAY} sec for ${TIME_PERIOD_SEND_NOTIF}  level=INFO  console=True
  Sleep  ${TIME_PERIOD_SEND_NOTIF}

UnSet alarm notification
  [Documentation]  stops alarm generation and create dictionary ${netconfAlarmGenerated}
  ...              for further checks
  [Tags]  smoke
  NTSimManagerNG.set_fault_delay_list_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  delay-period=${0}
  NTSimManagerNG.Set Netconf Config Nf    ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  faults-enabled=${False}
  ${netconfAlarmGenerated} =   NTSimManagerNG.Get Alarm Count    ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}
  # get generated alarms
  ${alarmsGenerated} = 	Get Dictionary Values 	${netconfAlarmGenerated}
  Log  ${alarmsGenerated}
  ${numAlarmsGenerated} =  evaluate  sum(${alarmsGenerated})
  Log  ${numAlarmsGenerated}
  Should Not Be Equal As Integers  ${numAlarmsGenerated}  0  msg=no alarm notifications generated
  Set Global Variable  ${netconfAlarmGenerated}


Verify alarm log
  [Tags]  smoke

  ${alarm_log_list} =  FaultManagementApp.get_alarm_log_list  source-type=Netconf
                                                        ...   timestamp=>=${start_time}
                                                        ...   node-id=${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}
  ${alarm_log_list_stats} =  get_counts_from_list  ${alarm_log_list}  severity  ${ALARM_SEVERITY_DEFAULT}
  Log Dictionary  ${alarm_log_list_stats}
  ${alarm_log_list_debug} =  FaultManagementApp.get_alarm_log_list  source-type=Netconf
  Log  ${alarm_log_list_debug}
  ${alarm_log_list_debug_backend} =  FaultManagementAppBackend.get_alarm_log_list  source-type=Netconf
                                                        ...   timestamp=>=${start_time}
  Log  ${alarm_log_list_debug_backend}

  ${critical_count}    Set Variable    ${alarm_log_list_stats}[Critical]
  ${major_count}       Set Variable    ${alarm_log_list_stats}[Major]
  ${minor_count}       Set Variable    ${alarm_log_list_stats}[Minor]
  ${warning_count}     Set Variable    ${alarm_log_list_stats}[Warning]
  ${nonalarmed_count}  Set Variable    ${alarm_log_list_stats}[NonAlarmed]

  ${netconf_critical_count}    Set Variable    ${netconfAlarmGenerated}[critical]
  ${netconf_major_count}       Set Variable    ${netconfAlarmGenerated}[major]
  ${netconf_minor_count}       Set Variable    ${netconfAlarmGenerated}[minor]
  ${netconf_warning_count}     Set Variable    ${netconfAlarmGenerated}[warning]
  ${netconf_nonalarmed_count}  Set Variable    ${netconfAlarmGenerated}[normal]

  Should Be True    ${critical_count} >= ${netconf_critical_count}
  Should Be True    ${major_count} >= ${netconf_major_count}
  Should Be True    ${minor_count} >= ${netconf_minor_count}
  Should Be True    ${warning_count} >= ${netconf_warning_count}
  Should Be True    ${nonalarmed_count} >= ${netconf_nonalarmed_count}


Verify current problem list
  [Tags]  smoke
  # fails immediatly if netconfAlarmGenerated is not set
  Log  ${netconfAlarmGenerated}
  ${alarm_log_list} =  FaultManagementApp.get_alarm_log_list  timestamp=>=${start_time}
  ${current_problem_list_calculated}=  FaultManagementApp.calculate_current_alarm_list   ${alarm_log_list}
  Log  ${current_problem_list_calculated}
  ${current_problem_list}=  FaultManagementApp.get_current_problem_list  timestamp=>=${start_time}
  Log  ${current_problem_list}
  ${current_problem_list_debug}=  FaultManagementApp.get_current_problem_list
  Log  ${current_problem_list_debug}
  ${current_problem_list_debug_backend}=  FaultManagementAppBackend.get_current_problem_list  timestamp=>=${start_time}
  Log  ${current_problem_list_debug_backend}
  ${current_problem_list_calculated_stats} =  get_counts_from_list  ${current_problem_list_calculated}  severity  ${ALARM_SEVERITY_DEFAULT}
  ${current_problem_list_stats} =  get_counts_from_list  ${current_problem_list}  severity  ${ALARM_SEVERITY_DEFAULT}
  Log Dictionary  ${current_problem_list_calculated_stats}
  Log Dictionary  ${current_problem_list_stats}
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${current_problem_list_stats}  Critical    ${current_problem_list_calculated_stats}[Critical]
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${current_problem_list_stats}  Major       ${current_problem_list_calculated_stats}[Major]
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${current_problem_list_stats}  Minor       ${current_problem_list_calculated_stats}[Minor]
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${current_problem_list_stats}  Warning     ${current_problem_list_calculated_stats}[Warning]

Verify alarm status bar
  [Tags]  smoke
  Sleep  10s  reason=wait update alarmstatus
  ${alarm_status_end} =  FaultManagementApp.get_alarm_status
  Log Dictionary  ${alarm_status_start}
  Log Dictionary  ${alarm_status_end}
  Run Keyword And Continue On Failure  Evaluate  ${alarm_status_end}[criticals]-${alarm_status_start}[criticals] == ${netconfAlarmGenerated}[critical]
  Run Keyword And Continue On Failure  Evaluate  ${alarm_status_end}[majors]-${alarm_status_start}[majors] == ${netconfAlarmGenerated}[major]
  Run Keyword And Continue On Failure  Evaluate  ${alarm_status_end}[minors]-${alarm_status_start}[minors] == ${netconfAlarmGenerated}[minor]
  Run Keyword And Continue On Failure  Evaluate  ${alarm_status_end}[warnings]-${alarm_status_start}[warnings] == ${netconfAlarmGenerated}[warning]

Remove networkelement connection
  ConnectApp.Remove network element connection  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}
  Run Keyword And Continue On Failure  ConnectApp.Should be equal connection status until time  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  not existing
  SDNCRestconfLibrary.Should Be Equal Connection Status Until Time    ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  not existing

