*** Settings ***
Documentation     Connects NTS manager of specific device type
...  NTS manager information are stored in test environment variable file <environment>
...  as dictionary NTS_MANAGER = {}
...  change device type on command line with  --variable  DEVICE_TYPE:ORAN
...  Enable alarms by setting fault-notification-delay-period and validate the alarms published by simulator against received by SDNR
Default Tags  fm  ves

Library  ConnectLibrary
Library  SDNCRestconfLibrary
Library  SDNCBaseLibrary
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
${DEVICE_TYPE}  _FILL_HERE_
${HOST}   ${NETWORK_FUNCTIONS}[${DEVICE_TYPE}][NETCONF_HOST]
${PORT}   ${NETWORK_FUNCTIONS}[${DEVICE_TYPE}][BASE_PORT]
${USERNAME}  ${NETWORK_FUNCTIONS}[${DEVICE_TYPE}][USER]
${PASSWORD}  ${NETWORK_FUNCTIONS}[${DEVICE_TYPE}][PASSWORD]
${FAULT_DELAY}  5
${TIME_PERIOD_SEND_NOTIFY}  20s
${PROCESS_TIME_NOTIF}  30s
&{ALARM_SEVERITY_DEFAULT}  Critical=${0}  Major=${0}  Minor=${0}  Warning=${0}  NonAlarmed=${0}


*** Test Cases ***
Setup NTS function
  [Tags]  nts  bringup
  [Documentation]  configure NTS manager to support restconf registration
  Add Network Element Connection   ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}    ${True}
  ...  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['IP']}     ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['PORT']}
  ...  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['USER']}    ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['PASSWORD']}
  ...  Connected
  SDNCRestconfLibrary.Should Be Equal Connection Status Until Time    ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}    Connected

Set alarm notification
  [Tags]  smoke
  NTSimManagerNG.clear_alarm_count  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}
  Sleep  1s  reason=insert time gap in log files
  ${start_time} =  Get Current Date  time_zone=UTC  result_format=%Y-%m-%dT%H:%M:%S.%f
  Sleep  1s  reason=insert time delay to account for time differences of container and host
  Set Global Variable  ${start_time}
  ${alarm_status_start} =  FaultManagementApp.get_alarm_status
  Set Global Variable  ${alarm_status_start}
  NTSimManagerNG.set_fault_delay_list_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  delay-period=${fault_delay}
  NTSimManagerNG.set_ves_config_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  faults-enabled=${True}
  Log  Send notification every ${FAULT_DELAY} sec for ${TIME_PERIOD_SEND_NOTIFY}  level=INFO  html=False  console=True  repr=False
  Sleep  ${TIME_PERIOD_SEND_NOTIFY}

UnSet alarm notification
  [Documentation]  stops alarm generation and create dictionary ${vesAlarmGenerated}
  ...              for further checks
  [Tags]  smoke
  NTSimManagerNG.set_fault_delay_list_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  delay-period=${0}
  NTSimManagerNG.set_ves_config_nf  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}
  ...                            faults-enabled=${False}
  Log  Wait ${PROCESS_TIME_NOTIF} to process notifications  level=INFO  html=False  console=True  repr=False
  Sleep  ${PROCESS_TIME_NOTIF}
  # get generated alarms
  ${vesAlarmGenerated} =  NTSimManagerNG.Get Alarm Count  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}
  ${alarmsGenerated} = 	Get Dictionary Values 	${vesAlarmGenerated}
  Log  ${alarmsGenerated}
  ${numAlarmsGenerated} =  evaluate  sum(${alarmsGenerated})
  Log  ${numAlarmsGenerated}
  Should Not Be Equal As Integers  ${numAlarmsGenerated}  0  msg=no alarm notifications generated
  Set Global Variable  ${vesAlarmGenerated}


Verify alarm log
  [Tags]  smoke
  # TODO: refactor for more then one SSH device (for loop)
  ${alarm_log_list_debug_backend} =  FaultManagementAppBackend.get_alarm_log_list  source-type=Ves
                                                        ...   timestamp=>=${start_time}
  Log  ${alarm_log_list_debug_backend}
  ${alarm_log_list} =  FaultManagementApp.get_alarm_log_list  source-type=Ves
                                                        ...   timestamp=>=${start_time}
  ${alarm_log_list_stats} =  get_counts_from_list  ${alarm_log_list}  severity  ${ALARM_SEVERITY_DEFAULT}
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${alarm_log_list_stats}  Critical    ${vesAlarmGenerated}[critical]
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${alarm_log_list_stats}  Major       ${vesAlarmGenerated}[major]
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${alarm_log_list_stats}  Minor       ${vesAlarmGenerated}[minor]
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${alarm_log_list_stats}  Warning     ${vesAlarmGenerated}[warning]
  Run Keyword And Continue On Failure  Dictionary Should Contain Item  ${alarm_log_list_stats}  NonAlarmed  ${vesAlarmGenerated}[normal]

Verify current problem list
  [Tags]  smoke
  ${alarm_log_list} =  FaultManagementApp.get_alarm_log_list  timestamp=>=${start_time}
  ${current_problem_list_calculated}=  FaultManagementApp.calculate_current_alarm_list   ${alarm_log_list}
  Log  ${current_problem_list_calculated}
  ${current_problem_list}=  FaultManagementApp.get_current_problem_list  timestamp=>=${start_time}
  Log  ${current_problem_list}
  ${current_problem_list_debug}=  FaultManagementApp.get_current_problem_list
  Log  ${current_problem_list_debug}
  ${current_problem_list_debug_backend}=  FaultManagementAppBackend.get_current_problem_list  timestamp=>=${start_time}
  Log  ${current_problem_list_debug_backend}
  ${current_problem_list_calculated_stats}=  get_counts_from_list  ${current_problem_list_calculated}  severity  ${ALARM_SEVERITY_DEFAULT}
  ${current_problem_list_stats}=  get_counts_from_list  ${current_problem_list}  severity  ${ALARM_SEVERITY_DEFAULT}
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
  Run Keyword And Continue On Failure  Evaluate  ${alarm_status_end}[criticals]-${alarm_status_start}[criticals] == ${vesAlarmGenerated}[critical]
  Run Keyword And Continue On Failure  Evaluate  ${alarm_status_end}[majors]-${alarm_status_start}[majors] == ${vesAlarmGenerated}[major]
  Run Keyword And Continue On Failure  Evaluate  ${alarm_status_end}[minors]-${alarm_status_start}[minors] == ${vesAlarmGenerated}[minor]
  Run Keyword And Continue On Failure  Evaluate  ${alarm_status_end}[warnings]-${alarm_status_start}[warnings] == ${vesAlarmGenerated}[warning]

Remove networkelement connection
  ConnectApp.Remove network element connection  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}
  Run Keyword And Continue On Failure  ConnectApp.Should be equal connection status until time  ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  not existing
  SDNCRestconfLibrary.Should Be Equal Connection Status Until Time    ${NETWORK_FUNCTIONS['${DEVICE_TYPE}']['NAME']}  not existing
