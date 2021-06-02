*** Settings ***
Documentation  healthcheck of system under test: sdnc server, sdnrdb are available
Library  ConnectLibrary
Library  SDNCBaseLibrary
Library  Collections
Library  ElasticSearchLibrary
Library  ConnectApp
Library  RequestsLibrary

Suite Setup  global suite setup    &{GLOBAL_SUITE_SETUP_CONFIG}
Suite Teardown  global suite teardown

*** Variables ***
&{headers}  Content-Type=application/json  Authorization=Basic

*** Test Cases ***
Test Is SDNR Node Available
    ${server_status}=    server is ready    ${SDNR_PROTOCOL}${SDNR_HOST}    ${SDNR_PORT}
    should be true    ${server_status}

Test Is SDNRDB Available
    ${es_version_info}=    get elastic search version info as dict
    ${length_of_response}=    get length    ${es_version_info}
    should be true    ${length_of_response}>${0}

Test Is SDNRDB Initialized
    ${res}=  check aliases
    Log  ${res}  level=INFO  html=False  console=False  repr=False
    Run Keyword If  not ${res}  Fatal Error

Test Is VES Collector available
    # curl -k -u sample1:sample1 https://172.40.0.1:8443
    ${auth}=  Create List  ${VESCOLLECTOR}[USERNAME]  ${VESCOLLECTOR}[PASSWORD]
    RequestsLibrary.Create Session  alias=ves  url=${VESCOLLECTOR}[SCHEME]://${VESCOLLECTOR}[IP]:${VESCOLLECTOR}[PORT]  headers=${headers}  auth=${auth}
    ${resp}=  RequestsLibrary.GET On Session  ves  /
    Should Be Equal As Strings  ${resp.text}  Welcome to VESCollector
    Should Be Equal As Strings  ${resp.status_code}  200
    RequestsLibrary.Delete All Sessions

