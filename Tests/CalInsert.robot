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
## Positive
Calculator insert With valid person details 
    [documentation]  Should return success when apply calculator insert with valid details
    ...  consist of 3 testcase: 
    ...    postive natid value
    ...    negative natid value
    ...    mixchars natid value
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user1_valid_details}  headers=&{headers}
    assert valid result
    ${response}=    POST  ${api_url}/calculator/insert  ${user2_valid_details}  headers=&{headers}
    assert valid result
    ${response}=    POST  ${api_url}/calculator/insert  ${user3_valid_details}  headers=&{headers}
    assert valid result
   
Calculator insert with valid person details but different rearrangement
    [documentation]  Should return success when the details are valid but the different arrangment from the JSON data
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user4_diffarrange_details}  headers=&{headers}
    assert valid result

Calculator insert With long characters name support
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user6_longCharSupport_name}  headers=&{headers}
    assert valid result

Calculator insert With long characters natid support
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user7_longCharSupport_natid}  headers=&{headers}
    assert valid result

## Negative
Calculator insert With missing content: natid
    [documentation]  Should return failed when the natid is not part of the JSON data
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_missing_natid}  headers=&{headers}
    assert Internal Server Error
    
Calculator insert With missing content: name
    [documentation]  Should return failed when the name is not part of the JSON data
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_missing_name}  headers=&{headers}
    assert Internal Server Error

Calculator insert With missing content: gender
    [documentation]  Should return failed when the gender is not part of the JSON data
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_missing_gender}  headers=&{headers}
    assert Internal Server Error

Calculator insert With missing content: birthday
    [documentation]  Should return failed when the birthday is not part of the JSON data
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_missing_birthday}  headers=&{headers}
    assert Internal Server Error
    
Calculator insert With missing content: salary
    [documentation]  Should return failed when the salary is not part of the JSON data
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_missing_salary}  headers=&{headers}
    assert Internal Server Error
    
Calculator insert With missing content: tax paid
    [documentation]  Should return failed when the taxpaid is not part of the JSON data
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_missing_taxpaid}  headers=&{headers}
    assert Internal Server Error

Calculator insert With empty content: natid
    [documentation]  Should return failed when the natid is part of the JSON data but the content is empty
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_empty_natid}  headers=&{headers}
    assert Internal Server Error

Calculator insert With empty content: name
    [documentation]  Should return failed when the name is part of the JSON data but the content is empty
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_empty_name}  headers=&{headers}
    assert Internal Server Error

Calculator insert With empty content: gender
    [documentation]  Should return failed when the gender is part of the JSON data but the content is empty
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_empty_gender}  headers=&{headers}
    assert Internal Server Error
    
Calculator insert With empty content: birthday
    [documentation]  Should return failed when the birthday is part of the JSON data but the content is empty
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_empty_birthday}  headers=&{headers}
    assert Internal Server Error

Calculator insert With empty content: salary
    [documentation]  Should return failed when the salary is part of the JSON data but the content is empty
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_empty_salary}  headers=&{headers}
    assert Internal Server Error
    
Calculator insert With empty content: tax paid
    [documentation]  Should return failed when the taxpaid is part of the JSON data but the content is empty
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_empty_taxpaid}  headers=&{headers}
    assert Internal Server Error


Calculator insert With invalid content: gender non-single characters
    [documentation]  Should return failed when the gender is invalid with more than 1 character
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_nonSingleChar_gender}  headers=&{headers}
    assert Internal Server Error

Calculator insert With invalid content: gender invalid characters
    [documentation]  Should return failed when the gender is invalid with other character value, other than acceptable "m" or "f"
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidChar_gender}  headers=&{headers}
    assert Internal Server Error

Calculator insert With invalid content: gender invalid characters big capped
    [documentation]  Should return failed when the gender is invalid with valid character value but in capped
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidCharbigcapped_gender}  headers=&{headers}
    assert Internal Server Error

Calculator insert With invalid content: birthday invalid date
    [documentation]  Should return failed when the birthday is invalid
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidDate_birthday}  headers=&{headers}
    assert Internal Server Error

Calculator insert With invalid content: birthday invalid date format
    [documentation]  Should return failed when the birthday format is invalid e.g 12Dec1991
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidDateFormat_birthday}  headers=&{headers}
    assert Internal Server Error

Calculator insert With invalid content: birthday invalid date negative value
    [documentation]  Should return failed when the birthday invalid in negative value
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidDateNegValue_birthday}  headers=&{headers}
    assert Internal Server Error

Calculator insert With invalid content: salary invalid negative value
    [documentation]  Should return failed when the salary invalid in negative value
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidNegValue_salary}  headers=&{headers}
    assert Internal Server Error

Calculator insert With invalid content: salary invalid mix letter and number value
    [documentation]  Should return failed when the salary invalid in mixture of letters and number
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidmixValue_salary}  headers=&{headers}
    assert Internal Server Error

Calculator insert With invalid content: tax Paid invalid negative value
    [documentation]  Should return failed when the taxpaid invalid in negative value
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidNegValue_taxPaid}  headers=&{headers}
    assert Internal Server Error

Calculator insert With invalid content: tax Paid invalid letter value
    [documentation]  Should return failed when the salary invalid in letter value, no number
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${response}=    POST  ${api_url}/calculator/insert  ${user5_invalidValueLetteronly_taxPaid}  headers=&{headers}
    assert Internal Server Error
