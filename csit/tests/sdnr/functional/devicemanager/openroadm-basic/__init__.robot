*** Settings ***
Documentation    Test suite for open-roadm devices
Suite Setup      My Setup
Force Tags       openroadm
Library          OperatingSystem

*** Variables ***


*** Keywords ***
My Setup
  Set Suite Variable    ${DEVICE_TYPE}  OPENROADM_6_1_0    children=true
  Set Suite Variable    ${CORE_MODEL}  Unsupported    children=true
  Set Suite Variable    ${DEVICE_TYPE_GUI}  O-ROADM    children=true
  ${yang_file} =  Get File  ${CURDIR}/yangCapabilities.txt
  Set Suite Variable    ${YANG_CAPABILITIES_FILE}  ${yang_file}  children=true


