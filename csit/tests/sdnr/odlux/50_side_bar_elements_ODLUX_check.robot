*** Settings ***
Documentation          Test to verify the existence and functionality of the ODLUX Side-Bar Elements.
    ...                Opens ODLUX and clicks on each Side-Bar Element (Data-driven), given in the SIDE_BAR_ELEMENT
    ...                column. Once clicking on the Side-Bar Element has been successful, a clickable web-element
    ...                given by the locator in the CHECK_CLICKABLE_BUTTON_VALUE column, will be checked for existence.
    ...                The web-element's By strategy to find the element, given by the CHECK_CLICKABLE_BUTTON_BY column,
    ...                (either Xpath or CSS_SELECTOR) has to be provided and is depended on the variable locator.
    ...                The test will Pass if both the Side-Bar Element and the clickable web-element exist, else Fail.
Library  UILib
Library  Collections

Test Template  Check Side Bar Elements

*** Variables ***
${MAKE_SCREENSHOTS}  ${True}
${ELEMENT_COUNT}  ${0}

*** Test Cases ***                                 SIDE_BAR_ELEMENT    CHECK_WEBELEMENT_BY           CHECK_WEBELEMENT_VALUE                                 CLICK_ON_WEB_ELEMET
Check if Side Bar Element Home exists              Home                CSS_SELECTOR                  ODLUX_WELCOME_TO_ODLUX_LABEL                           False
Check if Side Bar Element Connect exists           Connect             CSS_SELECTOR                  ODLUX_NETWORK_ELEMENTS_LIST_TAB_LABEL                  False
Check if Side Bar Element Fault exists             Fault               CSS_SELECTOR                  ODLUX_CURRENT_ALARMS_TABLE_LABEL                       False
Check if Side Bar Element Maintenance exists       Maintenance         CSS_SELECTOR                  ODLUX_MAINTENANCE_TABLE_FILTER_LIST_BUTTON_LABEL       False
Check if Side Bar Element Configuration exists     Configuration       CSS_SELECTOR                  ODLUX_TABLE_FILTER_LIST_BUTTON_LABEL                   False
Check if Side Bar Element Performance exists       Performance         CSS_SELECTOR                  ODLUX_PERFORMANCE_TABLE_FILTER_LIST_BUTTON_LABEL       False
Check if Side Bar Element Inventory exists         Inventory           CSS_SELECTOR                  ODLUX_INVENTORY_TABLE_LABEL                            False
Check if Side Bar Element Event_Log exists         Event_Log           CSS_SELECTOR                  ODLUX_EVENT_LOG_TABLE_FILTER_LIST_BUTTON_LABEL         False
Check if Side Bar Element Help exists              Help                CSS_SELECTOR                  ODLUX_HELP_AND_FAQ_LABEL                               False
Check if Side Bar Element About exists             About               CSS_SELECTOR                  ODLUX_ABOUT_COPY_TO_CLIPBOARD_LABEL                    False

Sidebar Elements Count
  [Template]  Check Side Bar Elements Count
  ${ELEMENT_COUNT}

*** Keywords ***
Check Side Bar Elements
    [Arguments]     ${side_bar_element}     ${check_webelement_by}    ${check_webelement_value}     ${click_on_web_element}
    ${ELEMENT_COUNT}=  Set Variable  ${${ELEMENT_COUNT}+${1}}
    Set Suite Variable    ${ELEMENT_COUNT}
    Refresh Current Browser Tab
    Log  ${side_bar_element}
    UILib.Click On Site Bar Element   side_bar_element=${side_bar_element}
    ${is_exist}=  Check If Web Element Exists   by=${check_webelement_by}   value=${check_webelement_value}
                                           ...  click_on_web_element=${click_on_web_element}
    Should Be True  ${is_exist}

Check Sidebar Elements Count
  [Arguments]     ${elements_count}
  ${sidebar_elements}=  Get All Sidebar Elements
  Log  ${sidebar_elements}
  ${current_sidebar_elements_count}=  Get Length  ${sidebar_elements}
  Should Be Equal As Integers    ${elements_count}    ${current_sidebar_elements_count}
    

