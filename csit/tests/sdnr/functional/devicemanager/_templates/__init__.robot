*** Settings ***
Documentation    Test suite for _FILL_HERE_ devices
Suite Setup      My Setup
Force Tags       _FILL_HERE_
#Library          SomeLibrary

*** Variables ***


*** Keywords ***
My Setup
  Set Suite Variable    ${DEVICE_TYPE}  _FILL_HERE_    children=true
  Set Suite Variable    ${CORE_MODEL}  _FILL_HERE_    children=true
  Set Suite Variable    ${DEVICE_TYPE_GUI}  _FILL_HERE_    children=true


