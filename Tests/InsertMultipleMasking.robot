*** Settings ***
Library    REST
Library    Collections
Library    String
Library    OperatingSystem
Variables   ../Resources/TestData/user.py

## TODO Teardown need to test
Test Teardown    POST         ${api_url}/calculator/rakeDatabase
*** Variables ***
${api_url}=       http://localhost:8080

*** Keywords ***
assert valid result
    Integer   response status  202
    String    response body    Alright

assert Internal Server Error
    Integer   response status  500
    String    response body error   Internal Server Error

*** Test Cases ***
US2_TC1: Calculator insert Multiple With array of valid person details
    [Tags]    Functional    Smoke
    [Documentation]  Test case to insert array
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insertMultiple  ${array_users}  headers=&{headers}
    assert valid result

US2_TC2: Calculator insert Multiple With empty array of valid person details
    [Tags]    Functional
    [Documentation]  Test case to insert empty array
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insertMultiple  []  headers=&{headers}
    assert valid result
US2_TC3: Calculator insert Multiple With array with 2 set of same person details
    [Tags]    Functional
    [Documentation]  Test case to insert array, consist 2 sets of same person details
    ...    Improvement: should do checks if the same details has input or not.
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insertMultiple  ${array_samedetails}  headers=&{headers}
    assert valid result
US2_TC4: Calculator insert Multiple With array of 1 invalid person details
    [Tags]    Functional
    [Documentation]  Test case to insert array with invalid/missing detail
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insertMultiple  ${array_invalidDetails}  headers=&{headers}
    assert Internal Server Error

 