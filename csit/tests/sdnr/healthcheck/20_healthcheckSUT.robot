*** Settings ***
Documentation  healthcheck of system under test: sdnc server, sdnrdb are available
Library  ConnectLibrary
Library  SDNCBaseLibrary
Library  Collections
Library  SDNRDBLib
Library  ConnectApp
Library  RequestsLibrary

Suite Setup  global suite setup    &{GLOBAL_SUITE_SETUP_CONFIG}
Suite Teardown  global suite teardown

*** Variables ***
&{headers}  Content-Type=application/json  Authorization=Basic
*** Test Cases ***
Test Is SDNR Node Available
    ${server_status}=    Server Is Ready
    should be true    ${server_status}

Test Is SDNRDB Available
    ${es_version_info}=    Get Sdnrdb Version Info As Dict
    ${length_of_response}=    Get Length    ${es_version_info}
    should be true    ${length_of_response}>${0}

Test Is SDNRDB Initialized
    ${res}=  Check Aliases
    Log  ${res}  level=INFO

Test Is VES Collector available
    # curl -k -u sample1:sample1 https://172.40.0.1:8443
    ${auth}=  Create List  ${VESCOLLECTOR}[USERNAME]  ${VESCOLLECTOR}[PASSWORD]
    ${IPV6_ENABLED}=  Get Variable Value    ${ENABLE_IPV6}  ${False}
    Log To Console    ${VESCOLLECTOR}[SCHEME]://[${VESCOLLECTOR}[IP]]:${VESCOLLECTOR}[PORT]
    IF    ${IPV6_ENABLED} != ${True}
        RequestsLibrary.Create Session  alias=ves  url=${VESCOLLECTOR}[SCHEME]://${VESCOLLECTOR}[IP]:${VESCOLLECTOR}[PORT]  headers=${headers}  auth=${auth}
    ELSE
        RequestsLibrary.Create Session  alias=ves  url=${VESCOLLECTOR}[SCHEME]://[${VESCOLLECTOR}[IP]]:${VESCOLLECTOR}[PORT]  headers=${headers}  auth=${auth}
    END
    ${resp}=  RequestsLibrary.GET On Session  ves  /
    Should Be Equal As Strings  ${resp.text}  Welcome to VESCollector
    Should Be Equal As Strings  ${resp.status_code}  200
    RequestsLibrary.Delete All Sessions

Test Version Info Contains Correct release
    ${VERSION_INFO_DICT}=   get_version_info_as_dict
    ${release}=	Get From Dictionary 	${VERSION_INFO_DICT["""version-info"""]} 	Opendaylight-release
    Should Contain    ${release}    ${RELEASE_VERSION}

