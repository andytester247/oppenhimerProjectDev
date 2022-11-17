*** Settings ***
Library    REST
Library    Collections
Library    String
Library    OperatingSystem
Variables   ../Resources/TestData/user.py

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
Calculator insert Multiple With array of valid person details
    [Documentation]  Test case to insert array
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insertMultiple  ${array_users}  headers=&{headers}
    assert valid result

Calculator insert Multiple With empty array of valid person details
    [Documentation]  Test case to insert empty array
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insertMultiple  []  headers=&{headers}
    assert valid result
Calculator insert Multiple With array with 2 set of same person details
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insertMultiple  ${array_samedetails}  headers=&{headers}
    assert valid result
Calculator insert Multiple With array of 1 invalid person details
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insertMultiple  ${array_invalidDetails}  headers=&{headers}
    assert Internal Server Error

Calculator validation tax relief to check natid masking function
    [documentation]  Should return success with masking from 5th onwards
    ${headers}=  Create Dictionary  Content-Type=application/json

    # no masking 1st to 4th chars
    ${response}=    POST  ${api_url}/calculator/insertMultiple  ${array_user0masking}  headers=&{headers}
    assert valid result
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body 
    ${targetfield1}=  Convert To String  ${resArray}[-1][-1]
    Should Contain Any    ${targetfield1}  'natid': '1234'

    # 5th char masked
    ${response}=    POST  ${api_url}/calculator/insertMultiple  ${array_user1masking}  headers=&{headers}
    assert valid result
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body 
    ${targetfield1}=  Convert To String  ${resArray}[-1][-1]
    Should Contain Any    ${targetfield1}  'natid': '1234$'

    # 6th char masked
    ${response}=    POST  ${api_url}/calculator/insertMultiple  ${array_user2masking}  headers=&{headers}
    assert valid result
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body 
    ${targetfield1}=  Convert To String  ${resArray}[-1][-1]
    Should Contain Any    ${targetfield1}  'natid': '1234$$'  