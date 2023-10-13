*** Settings ***

Resource          ./sdnc-properties.robot

Library           Collections
Library           RequestsLibrary
Library           OperatingSystem
# Library           HttpLibrary.HTTP


*** Keywords ***

Create SDNC RESTCONF Session
    [Documentation]    Create session to OpenDaylight controller
    ${auth}=  Create List  ${ODL_USER}  ${ODL_PASSWORD}
    Create Session  sdnc_restconf  ${SDNC_RESTCONF_URL}  auth=${auth}

Send Post File And Validate Response
    [Documentation]    POST file contents to OpenDaylight controller
    [Arguments]  ${url}  ${path}  ${resp_code}
    Create SDNC RESTCONF Session
    ${body}=      Get File     ${path}
    &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json    Accept=application/json
    ${resp}=  POST On Session  sdnc_restconf  ${url}  headers=${headers}  data=${body}  expected_status=${resp_code}


Send Empty Post Request And Validate Response
    [Documentation]    POST with no content to OpenDaylight controller
    [Arguments]  ${url}   ${resp_code}
    Create SDNC RESTCONF Session
    &{headers}=  Create Dictionary    Content-Type=application/json    Content-Length=0  Accept=application/json
    ${resp}=  POST On Session  sdnc_restconf  ${url}  headers=${headers}  expected_status=${resp_code}
    
Send Get Request And Validate Response Sdnc
    [Documentation]   GET from Opendaylight controller and validate received response
    [Arguments]   ${url}  ${resp_code}
    CREATE SDNC RESTCONF Session
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=     GET On Session    sdnc_restconf    ${url}    headers=${headers}  expected_status=${resp_code}

Send Get Request And Validate TLS Connection Response
    [Documentation]   Create NETCONF mount and validate TLS connection
    [Arguments]   ${url}  ${resp_code}
    Create SDNC RESTCONF Session
    ${mount}=    Get File    ${REQUEST_DATA_PATH}${/}mount.xml
    &{headers}=  Create Dictionary   Content-Type=application/xml    Accept=application/xml
    ${resp}=    PUT On Session    sdnc_restconf    ${url}    data=${mount}    headers=${headers}  expected_status=201
    Sleep  60
    &{headers1}=  Create Dictionary  Content-Type=application/json    Accept=application/json
    ${resp1}=    GET On Session    sdnc_restconf    ${PNFSIM_MOUNT_PATH}    headers=${headers1}  expected_status=${resp_code}


Send Delete Request And Validate PNF Mount Deleted
    [Documentation]   Disconnect NETCONT mount and validate
    [Arguments]   ${url}  ${resp_code}
    Create SDNC RESTCONF Session
    ${mount}=    Get File   ${REQUEST_DATA_PATH}${/}mount.xml
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${deleteresponse}=    DELETE On Session    sdnc_restconf    ${url}    data=${mount}    headers=${headers}  expected_status=${resp_code}
    Sleep  30
    ${del_topology}=    DELETE On Session    sdnc_restconf    ${SDNC_NETWORK_TOPOLOGY}  expected_status=${resp_code}
    ${del_keystore}=    DELETE On Session    sdnc_restconf    ${SDNC_KEYSTORE_CONFIG_PATH}


