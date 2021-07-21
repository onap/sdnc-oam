*** Settings ***
Documentation    Test suite for o-ran devices
Suite Setup      My Setup
Force Tags       o-ran
Library          OperatingSystem

*** Variables ***


*** Keywords ***
My Setup
  Set Suite Variable    ${DEVICE_TYPE}  O_RAN_FH   children=true
  Set Suite Variable    ${CORE_MODEL}  Unsupported    children=true
  Set Suite Variable    ${DEVICE_TYPE_GUI}  O-RAN    children=true
  ${yang_file} =  Get File  ${CURDIR}/yangCapabilities.txt
  Set Suite Variable    ${YANG_CAPABILITIES_FILE}  ${yang_file}  children=true


