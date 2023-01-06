*** Settings ***
Library    REST
Library    Collections
Library    String
Library    OperatingSystem
Library    SeleniumLibrary
Library    Process
Test Teardown    POST         ${api_url}/calculator/rakeDatabase

*** Variables ***
${api_url}=       http://localhost:8080
@{BROWSERS}       Chrome    firefox    edge
@{FILEFORMATS}    testfile.pdf    testfile.txt    testfile.xlsx    testfile.xls

*** Test Cases ***

US5_TC1: Should able to dispense tax relief: Chrome|Firefox|Edge
    [Tags]    Functional    Smoke
    [Documentation]  Should able to display tax relief successfully when the Cash dispensed button clicked
    ...  covering same testcase with 3 different browsers:
    ...    Chrome
    ...    Firefox
    ...    Edge
    FOR    ${BROWSER}    IN    @{BROWSERS}
    Open Browser    ${api_url}   ${BROWSER}
    ${webe}=    Get WebElement    xpath://html/body/div/div[2]/div/a[2]
    ${button_color}=    Call Method    ${webe}    value_of_css_property   background-color
    Log To Console    ${button_color}
    Should Match Regexp    ${button_color}    .*220, 53, 69.*
    
    Click Button    ${webe}
    ${cashDispendTxt}=    Get WebElement    xpath://html/body/div/div/div/main/div/div/div
    Element Should Contain    ${cashDispendTxt}    Cash dispensed

    Close Browser
    END