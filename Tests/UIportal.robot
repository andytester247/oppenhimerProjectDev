*** Settings ***
Library    REST
Library    Collections
Library    String
Library    OperatingSystem
Library    SeleniumLibrary
Library    Process
## TODO Teardown need to test
Test Teardown    POST         ${api_url}/calculator/rakeDatabase

*** Variables ***
${api_url}=       http://localhost:8080
@{BROWSERS}       Chrome    firefox    edge
@{FILEFORMATS}    testfile.pdf    testfile.txt    testfile.xlsx    testfile.xls

*** Test Cases ***
US3_TC1: Should failed to upload to portal with csv with no header: Chrome|Firefox|Edge
    [Tags]    Functional
    [Documentation]  Should not able to upload to portal when the csv file has no header
    ...  covering same testcase with 3 different browsers: 
    ...    Chrome
    ...    Firefox
    ...    Edge
    FOR    ${BROWSER}    IN    @{BROWSERS}
    Open Browser    ${api_url}   ${BROWSER}
    ${webelement1}=    Get WebElement    xpath://html/body/div/div[2]/div/div[1]/div[2]/input
    ${headers}=  Create Dictionary  Content-Type=multipart/form-data; boundary=YourBoundaryOfChoiceHere
    ${newPathCSVfile}=    Join Path    ${CURDIR}/../Resources/TestData    listusers_noheader.csv
    Choose File    ${webelement1}    ${newPathCSVfile}
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1]
    Should Not Contain Any    ${targetfield}  natid': '1231$$$
    Should Not Contain Any    ${targetfield}  relief': '1123$

    Close Browser
    END
    
US3_TC2: Should failed to upload to portal with incorrect file format e.g: .PDF : Chrome|Firefox|Edge
    [Tags]    Functional
    [Documentation]  Should failed to upload to portal when a different file format is in used.
    ...  covering Chrome browser with different supported file formats
    ...    PDF
    ...    excel (xls, xlsx)
    ...    text  
    FOR    ${FILEFORMAT}    IN    @{FILEFORMATS}
        Open Browser    ${api_url}   Chrome
        ${webelement1}=    Get WebElement    xpath://html/body/div/div[2]/div/div[1]/div[2]/input
        ${headers}=  Create Dictionary  Content-Type=multipart/form-data; boundary=YourBoundaryOfChoiceHere
        ${newPathCSVfile}=    Join Path    ${CURDIR}/../Resources/TestData    ${FILEFORMAT}
        Choose File    ${webelement1}    ${newPathCSVfile}

        ${headers}=  Create Dictionary  Content-Type=application/json
        ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
        Integer   response status  200
        ${resArray}=    Array    response body  
        Log To Console    ${resArray}  
        ${targetfield}=  Convert To String  ${resArray}[-1]
        Should Not Contain Any    ${targetfield}  natid': '1231$$$
        Should Not Contain Any    ${targetfield}  relief': '1123$

        Close Browser
    END

US3_TC3: Should able to upload to portal with csv with valid content: Chrome|Firefox|Edge
    [Tags]    Functional    Smoke
    [Documentation]  Should able to upload to portal successfully when the csv file has valid content
    ...  covering same testcase with 3 different browsers: 
    ...    Chrome
    ...    Firefox
    ...    Edge
    FOR    ${BROWSER}    IN    @{BROWSERS}
    Open Browser    ${api_url}   ${BROWSER}
    ${webelement1}=    Get WebElement    xpath://html/body/div/div[2]/div/div[1]/div[2]/input
    ${headers}=  Create Dictionary  Content-Type=multipart/form-data; boundary=YourBoundaryOfChoiceHere
    ${newPathCSVfile}=    Join Path    ${CURDIR}/../Resources/TestData    testfile.csv
    Choose File    ${webelement1}    ${newPathCSVfile}

    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Should Contain Any    ${targetfield}  natid': '1123$
    Should Contain Any    ${targetfield}  relief': '495.00

    Close Browser
    END

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