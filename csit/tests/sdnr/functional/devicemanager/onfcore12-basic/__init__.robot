*** Settings ***
Documentation    Test suite for onf core 1.2 devices
Suite Setup      My Setup
Force Tags       onf-core-12
Library          OperatingSystem

*** Variables ***


*** Keywords ***
My Setup
  Set Suite Variable    ${DEVICE_TYPE}  ONF_CORE_1_2    children=true
  Set Suite Variable    ${CORE_MODEL}   2017-03-20    children=true
  Set Suite Variable    ${DEVICE_TYPE_GUI}  Wireless    children=true
  ${yang_file} =  Get File  ${CURDIR}/yangCapabilities.txt
  Set Suite Variable    ${YANG_CAPABILITIES_FILE}  ${yang_file}  children=true
  Set Suite Variable    ${IS_SUPERVISION_ALARM}  ${True}


