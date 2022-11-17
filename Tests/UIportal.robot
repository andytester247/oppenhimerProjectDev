*** Settings ***
Library    REST
Library    Collections
Library    String
Library    OperatingSystem
Library    SeleniumLibrary
Library    Process

*** Variables ***
${api_url}=       http://localhost:8080
${BROWSER}        Chrome
*** Test Cases ***

Should not able to upload csv success to portal, that has no header
    Open Browser    ${api_url}    ${BROWSER}
    ${webelement1}=    Get WebElement    xpath://html/body/div/div[2]/div/div[1]/div[2]/input
    ${headers}=  Create Dictionary  Content-Type=multipart/form-data; boundary=YourBoundaryOfChoiceHere
    Choose File    ${webelement1}    ${CURDIR}//listusers_noheader.csv
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Should Not Contain Any    ${targetfield}  natid': '1231$$$
    Should Not Contain Any    ${targetfield}  relief': '1123$

Should able to upload csv file to portal
    Open Browser    ${api_url}    ${BROWSER}
    ${webelement1}=    Get WebElement    xpath://html/body/div/div[2]/div/div[1]/div[2]/input
    ${headers}=  Create Dictionary  Content-Type=multipart/form-data; boundary=YourBoundaryOfChoiceHere
    Choose File    ${webelement1}    ${CURDIR}//testfile.csv

    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Should Contain Any    ${targetfield}  natid': '1123$
    Should Contain Any    ${targetfield}  relief': '495.00

Should able to dispense tax relief
    Open Browser    ${api_url}    ${BROWSER}
    ${webe}=    Get WebElement    xpath://html/body/div/div[2]/div/a[2]
    Click Button    ${webe}
    ${cashDispendTxt}=    Get WebElement    xpath://html/body/div/div/div/main/div/div/div
    Element Should Contain    ${cashDispendTxt}    Cash dispensed    