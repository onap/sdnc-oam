*** Settings ***
Library           Collections
Library           Process
Library           RequestsLibrary
Library           String
Library           OperatingSystem


*** Variables ***
${DMAAP_URL}                              http://172.40.0.80:3904/events
${POST_DMAAP_EVENT_FOR_RAN_SLICE_MGMT_URL}      http://172.40.0.80:3904/events/RAN-Slice-Mgmt

*** Test Cases ***


Trigger Allocate flow
        Create Session  dmaap  ${DMAAP_URL}
        ${headers}=    Create Dictionary    Content-Type    application/json
        ${data}=   Get File      ${CURDIR}/test-data/allocate-data.json
        ${response}=    Evaluate    requests.post('${POST_DMAAP_EVENT_FOR_RAN_SLICE_MGMT_URL}', data=$data)
        Should Be Equal As Strings  ${response.status_code}  200

