*** Settings ***

Resource          ./sdnc-properties.robot

Library           Collections
Library 	      RequestsLibrary
Library           OperatingSystem


*** Keywords ***

Create SDNC RESTCONF Session
    [Documentation]    Create session to OpenDaylight controller
    ${auth}=  Create List  ${ODL_USER}  ${ODL_PASSWORD}
    Create Session  sdnc_restconf  ${SDNC_RESTCONF_URL}  auth=${auth}

Send Post Request And Validate Response
    [Documentation]    Send POST request to passed URL and validate received response
    [Arguments]  ${path}  ${body}  ${resp_code}
    Create SDNC RESTCONF Session
    &{headers}=  Create Dictionary    Authorization=Basic YWRtaW46S3A4Yko0U1hzek0wV1hsaGFrM2VIbGNzZTJnQXc4NHZhb0dHbUp2VXkyVQ==    Content-Type=application/json    Accept=application/json
    ${resp}=  POST On Session  sdnc_restconf  ${path}  headers=${headers}  json=${body}  expected_status=${resp_code}

Send Empty Post Request And Validate Response
    [Documentation]    Send POST request to passed URL and validate received response
    [Arguments]  ${path}   ${resp_code}
    Create SDNC RESTCONF Session
    &{headers}=  Create Dictionary    Content-Type=application/json    Content-Length=0  Accept=application/json
    ${resp}=  POST On Session  sdnc_restconf  ${path}  headers=${headers}  expected_status=${resp_code}
    
Send Get Request And Validate Response Sdnc
    [Documentation]   Send request to passed url and validate received response
    [Arguments]   ${path}  ${resp_code}
    CREATE SDNC RESTCONF Session
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}= 	GET On Session    sdnc_restconf    ${path}    headers=${headers}  expected_status=${resp_code}

Send Get Request And Validate TLS Connection Response
    [Documentation]   Send request to passed url and validate received response
    [Arguments]   ${path}  ${resp_code}
    Create SDNC RESTCONF Session
    ${mount}=    Get File    ${REQUEST_DATA_PATH}${/}mount.xml
    &{headers}=  Create Dictionary   Content-Type=application/xml    Accept=application/xml
    ${resp}=    PUT On Session    sdnc_restconf    ${path}    data=${mount}    headers=${headers}  expected_status=201
    Sleep  30
    &{headers1}=  Create Dictionary  Content-Type=application/json    Accept=application/json
    ${resp1}=    GET On Session    sdnc_restconf    ${PNFSIM_MOUNT_PATH}    headers=${headers1}  expected_status=${resp_code}


Send Delete Request And Validate PNF Mount Deleted
    [Documentation]   Send request to passed url and validate received response
    [Arguments]   ${path}  ${resp_code}
    Create SDNC RESTCONF Session
    ${mount}=    Get File   ${REQUEST_DATA_PATH}${/}mount.xml
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${deleteresponse}=    DELETE On Session    sdnc_restconf    ${path}    data=${mount}    headers=${headers}  expected_status=${resp_code}
    Sleep  30
    ${del_topology}=    DELETE On Session    sdnc_restconf    ${SDNC_NETWORK_TOPOLOGY}  expected_status=${resp_code}
    ${del_keystore}=    DELETE On Session    sdnc_restconf    ${SDNC_KEYSTORE_CONFIG_PATH}


