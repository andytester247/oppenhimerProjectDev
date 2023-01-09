*** Settings ***
Library    REST
Library    Collections
Library    String
Library    OperatingSystem
Variables   ../Resources/TestData/user.py
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
## Positive
US1_TC1: Calculator insert With valid person details
    [Tags]    Functional    smoke
    [documentation]  Should return success when apply calculator insert with valid details
    ...  consist of 4 testcase: 
    ...    postive natid value
    ...    negative natid value
    ...    mixchars natid value
    ...    postive natid value of 1 million numberic characters
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user1_valid_details}  headers=&{headers}
    assert valid result
    ${response}=    POST  ${api_url}/calculator/insert  ${user2_valid_details}  headers=&{headers}
    assert valid result
    ${response}=    POST  ${api_url}/calculator/insert  ${user3_valid_details}  headers=&{headers}
    assert valid result
    ${response}=    POST  ${api_url}/calculator/insert  ${user0_valid_details}  headers=&{headers}
    assert valid result
    
US1_TC2: Calculator insert with valid person details but different rearrangement
    [Tags]    Functional
    [documentation]  Should return success when the details are valid but the different arrangment from the JSON data
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user4_diffarrange_details}  headers=&{headers}
    assert valid result

US1_TC3: Calculator insert With long characters name support
    [Tags]    Functional
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user6_longCharSupport_name}  headers=&{headers}
    assert valid result

US1_TC4: Calculator insert With long characters natid support
    [Tags]    Functional
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user7_longCharSupport_natid}  headers=&{headers}
    assert valid result

## Negative
US1_TC5: Calculator insert With missing content: natid
    [Tags]    Functional    smoke
    [documentation]  Should return failed when the natid is not part of the JSON data
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_missing_natid}  headers=&{headers}
    assert Internal Server Error
    
US1_TC6: Calculator insert With missing content: name
    [Tags]    Functional
    [documentation]  Should return failed when the name is not part of the JSON data
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_missing_name}  headers=&{headers}
    assert Internal Server Error

US1_TC7: Calculator insert With missing content: gender
    [Tags]    Functional
    [documentation]  Should return failed when the gender is not part of the JSON data
    ...              Bug: Should failed when the gender is missing 
    ...              Improvement: Checks on missing gender, should be available on API Calculator Insert
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_missing_gender}  headers=&{headers}
    assert Internal Server Error

US1_TC8: Calculator insert With missing content: birthday
    [Tags]    Functional
    [documentation]  Should return failed when the birthday is not part of the JSON data
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_missing_birthday}  headers=&{headers}
    assert Internal Server Error
    
US1_TC9: Calculator insert With missing content: salary
    [Tags]    Functional
    [documentation]  Should return failed when the salary is not part of the JSON data
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_missing_salary}  headers=&{headers}
    assert Internal Server Error
    
US1_TC10: Calculator insert With missing content: tax paid
    [Tags]    Functional    smoke
    [documentation]  Should return failed when the taxpaid is not part of the JSON data
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_missing_taxpaid}  headers=&{headers}
    assert Internal Server Error

US1_TC11: Calculator insert With empty content: natid
    [Tags]    Functional
    [documentation]  Bug: Should return failed when the natid is part of the JSON data but the content is empty
    ...              Improvement: Checks on empty content should be available on API Calculator Insert
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_empty_natid}  headers=&{headers}
    assert Internal Server Error

US1_TC12: Calculator insert With empty content: name
    [Tags]    Functional
    [documentation]  Bug: Should return failed when the name is part of the JSON data but the content is empty
    ...              Improvement: Checks on empty content should be available on API Calculator Insert
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_empty_name}  headers=&{headers}
    assert Internal Server Error

US1_TC13: Calculator insert With empty content: gender
    [Tags]    Functional
    [documentation]  Bug: Should return failed when the gender is part of the JSON data but the content is empty
    ...              Improvement: Checks on empty content should be available on API Calculator Insert
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_empty_gender}  headers=&{headers}
    assert Internal Server Error
    
US1_TC14: Calculator insert With empty content: birthday
    [Tags]    Functional
    [documentation]  Should return failed when the birthday is part of the JSON data but the content is empty
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_empty_birthday}  headers=&{headers}
    assert Internal Server Error

US1_TC15: Calculator insert With empty content: salary
    [Tags]    Functional
    [documentation]  Should return failed when the salary is part of the JSON data but the content is empty
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_empty_salary}  headers=&{headers}
    assert Internal Server Error
    
US1_TC16: Calculator insert With empty content: tax paid
    [Tags]    Functional
    [documentation]  Should return failed when the taxpaid is part of the JSON data but the content is empty
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_empty_taxpaid}  headers=&{headers}
    assert Internal Server Error

US1_TC17: Calculator insert With invalid content: gender non-single characters
    [Tags]    Functional    smoke
    [documentation]  Should return failed when the gender is invalid with more than 1 character
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_nonSingleChar_gender}  headers=&{headers}
    assert Internal Server Error

US1_TC18: Calculator insert With invalid content: gender invalid characters
    [Tags]    Functional
    [documentation]  Bug: Should return failed when the gender is invalid with other character value, other than acceptable "m" or "f"
    ...              Improvement: Checks on invalid gender character, should be available on API Calculator Insert
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidChar_gender}  headers=&{headers}
    assert Internal Server Error

US1_TC19: Calculator insert With invalid content: gender invalid characters big capped
    [Tags]    Functional
    [documentation]  Bug: Should return failed when the gender is invalid with valid character value but in capped
    ...              Improvement: Checks on Capped gender character, should be available on API Calculator Insert
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidCharbigcapped_gender}  headers=&{headers}
    assert Internal Server Error

US1_TC20: Calculator insert With invalid content: birthday invalid date
    [Tags]    Functional    smoke
    [documentation]  Should return failed when the birthday is invalid
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidDate_birthday}  headers=&{headers}
    assert Internal Server Error

US1_TC21: Calculator insert With invalid content: birthday invalid date format
    [Tags]    Functional
    [documentation]  Should return failed when the birthday format is invalid e.g 12Dec1991
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidDateFormat_birthday}  headers=&{headers}
    assert Internal Server Error

US1_TC22: Calculator insert With invalid content: birthday invalid date negative value
    [Tags]    Functional
    [documentation]  Should return failed when the birthday invalid in negative value
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidDateNegValue_birthday}  headers=&{headers}
    assert Internal Server Error

US1_TC23: Calculator insert With invalid content: salary invalid negative value
    [Tags]    Functional
    [documentation]  Bug: Should return failed when the salary invalid in negative value
    ...              Improvement: Checks on negative value on Salary should be available on API Calculator Insert
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidNegValue_salary}  headers=&{headers}
    assert Internal Server Error

US1_TC24: Calculator insert With invalid content: salary invalid mix letter and number value
    [Tags]    Functional    smoke
    [documentation]  Should return failed when the salary invalid in mixture of letters and number
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidmixValue_salary}  headers=&{headers}
    assert Internal Server Error

US1_TC25: Calculator insert With invalid content: tax Paid invalid negative value
    [Tags]    Functional
    [documentation]  Should return failed when the taxpaid invalid in negative value
    ...              Bug: Expect error when tax paid is in negative value
    ...              Improvement: Checks on negative value on tax should be available on API Calculator Insert
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidNegValue_taxPaid}  headers=&{headers}
    assert Internal Server Error

US1_TC26: Calculator insert With invalid content: tax Paid invalid letter value
    [Tags]    Functional
    [documentation]  Should return failed when the salary invalid in letter value, no number
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidValueLetteronly_taxPaid}  headers=&{headers}
    assert Internal Server Error