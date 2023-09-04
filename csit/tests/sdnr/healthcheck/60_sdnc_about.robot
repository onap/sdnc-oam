*** Settings ***
Documentation          Test to check the about dicts of each SDNC instance after a deployment through instance which has
...                    an view over each other instance. The dictionaries will be checked for excpected keys defined
...                    in the Variables section.
Library  ConnectLibrary
Library  SDNCBaseLibrary
Library  ConnectApp
Library  Collections
Library  RequestsLibrary
Library  String
Library  utility

Suite Setup     Suite Start Default
Suite Teardown  Global Suite Teardown

*** Variables ***
@{EXPECTED_KEYS_VERSION_INFO_DICT}  ONAP-release  ONAP-release-version  Opendaylight-release  ONAP-CCSDK-version
...  Build-timestamp  Yangtools-version  MD-SAL-version  SDN-R packages version  Cluster size
${CHECK_FOR_READY_STATE}  ${False}

*** Keywords ***
Suite Start Default
    ${SDNR_HOST}=  Set Variable  ${ONE_TO_N_SUBDOMAIN}.${BASE_URL}
    set suite variable   ${SDNR_HOST}
    Global Suite Setup

*** Test Cases ***

Check About Dicts
  ${sdnc_node_prefix}=  Get Variable Value    ${SDNC_INSTANCE_PREFIX}
  IF  """${sdnc_node_prefix}""" != 'None'
      ${res}=  Check About Dict Of Sdnc Master  expected_keys=@{EXPECTED_KEYS_VERSION_INFO_DICT}
                                           ...  sdnc_node_prefix=${sdnc_node_prefix}
  ELSE
      ${res}=  Check About Dict Of Sdnc Master  expected_keys=@{EXPECTED_KEYS_VERSION_INFO_DICT}
  END
  Should Be True    ${res}

Check SDNR Count
  ${expected_sdnr_count}=  Get Length    ${SDNR_PREFIX_LIST}

  ${first_sdnr}=  Get From List    ${SDNR_PREFIX_LIST}    ${0}

  ${int_list}  ${sdnr_base_name}=  Extract Integers From String And Return Template  ${first_sdnr}

  FOR    ${counter}    IN RANGE    ${0}    ${9}
      ${sdnr}=  Format String    ${sdnr_base_name}  index_0=${counter}
      ${host}=  Set Variable  ${sdnr}.${BASE_URL}
      TRY
          ${response}=  GET  ${SDNR_PROTOCOL}${host}/ready  verify=${False}
      EXCEPT
          ${current_sdnr_count}=  Set Variable  ${counter}
           Should Be Equal As Integers    ${expected_sdnr_count}    ${current_sdnr_count}
           BREAK
      END
  END
