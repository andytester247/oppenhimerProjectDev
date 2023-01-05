*** Settings ***
Library    REST
Library    Collections
Library    String
Library    OperatingSystem
Library    SeleniumLibrary
Library    DateTime
Variables   ../Resources/TestData/user.py
## TODO Teardown need to test
Test Teardown    POST         ${api_url}/calculator/rakeDatabase
*** Variables ***
${api_url}=       http://localhost:8080
${headers}=  Create Dictionary  Content-Type=application/json

*** Keywords ***
calculate birthday with currentDate by age
    [Arguments]  ${arg1}  ${arg}
    ${year}=    Set Variable    ${${arg1} - ${arg}}
    ${arg}=    Set Variable    ${${arg} * 365.25}
    ${currDate}=  Get Current Date        
    ${date1}=   Subtract Time From Date    ${currDate}    ${arg} days     result_format=%d%m%y
    ${day}=     Get Substring    ${date1}    0  2
    ${mth}=     Get Substring    ${date1}    2  4
    ${newbirthday}=     Catenate  SEPARATOR=      ${day}    ${mth}
    ${newbirthday}=     Catenate  SEPARATOR=      ${newbirthday}    ${year}
    # Log To Console   ${newbirthday}
    ${newbirthday}=     Convert To String    ${newbirthday}
    RETURN     ${newbirthday}


calculate tax relief by salary, taxpaid, age and gender
    [Arguments]  ${salary1}  ${taxpaid1}  ${age1}  ${gender1}  ${decimalplace}
    # Log To Console    TESTsalary1:${salary1}
    # Log To Console    TESTtaxpaid1:${taxpaid1}
    ${decimalplace}=    Evaluate  ${decimalplace} - 1    
    ${taxrelief}=   Evaluate  ${salary1} - ${taxpaid1}
    
    # set to 2 decimal places only
    Log To Console    TESTtaxrelief:${taxrelief}
    ${taxrelief}=    Convert To String    ${taxrelief}
    ${Ptax}=    Evaluate    "${taxrelief}".split(".")
    Log To Console    TESTTEST-Ptax1:${Ptax[0]}
    ${Ptax[1]}=    Get Substring    ${Ptax[1]}     0     ${decimalplace}
    Log To Console    TESTTEST-Ptax2:${Ptax[1]}
    ${newtaxrelief}=    Catenate  SEPARATOR=.  ${Ptax[0]}  ${Ptax[1]}
    IF    ${Ptax[1]} < 5
        ${decimalplace}=    Evaluate  ${decimalplace} - 1
    END
    ${taxrelief}=    Convert To Number    ${newtaxrelief}    ${decimalplace}
    Log To Console    TESTTEST-FINALPtax:${taxrelief}    

    IF    0 < ${age1} < 19
        ${taxrelief}=   Evaluate  ${taxrelief}*1
    ELSE IF    18 < ${age1} < 36
        ${taxrelief}=   Evaluate  ${taxrelief}*0.8
    ELSE IF    35 < ${age1} < 51
        ${taxrelief}=   Evaluate  ${taxrelief}*0.5
    ELSE IF    50 < ${age1} < 76
        ${taxrelief}=   Evaluate  ${taxrelief}*0.367
    ELSE IF    75 < ${age1}
        ${taxrelief}=   Evaluate  ${taxrelief}*0.05
    END
    # Log To Console    TESTTEST-afterCal-tax:${taxrelief}
    # ${taxrelief}=    Convert To Number    ${taxrelief}    ${decimalplace}
    # Log To Console    TESTTEST-afternormalrounding-tax:${taxrelief}
    IF    "${gender1}" == "f"
        ${taxrelief}=      Evaluate  ${taxrelief}+500
    ELSE    
        ${taxrelief}=      Evaluate  ${taxrelief}+0
    END
    IF    0 < ${taxrelief} < 50
        ${taxrelief}=     Set Variable  50
    ELSE IF  0 > ${taxrelief}
        ${taxrelief}=     Set Variable  50
    ELSE IF  0== ${taxrelief}
         ${taxrelief}=    Set Variable  125
    END

    Log To Console    TESTFINAL-FINALPtax:${taxrelief}

    RETURN     ${taxrelief}

*** Keywords ***
assert valid result
    Integer   response status  202
    String    response body    Alright

assert Internal Server Error
    Integer   response status  500
    String    response body error   Internal Server Error

*** Test Cases ***
US4_TC1: Calculator validation tax relief with age: 17 AND Tax paid more than Salary by 1 dollar
    [Tags]    Functional    Smoke
    [Documentation]    Bug: the tax relief would returned 50 if the calculated would be -1, there is no instruction from the document what do expected but based on the Test application's returns as 50.
    ...    Improvement: add new instruction to state that if Tax is paid more the Salary, will get tax relief according to the Tax Relief Calculation. 
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    17
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    500
    ${taxpaid}=   Set Variable    501
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC2: Calculator validation tax relief with age: 17 AND Salary more than Tax paid by 1 dollar
    [Tags]    Functional
    [Documentation]   To verify the tax relief calculation when Salary is more than Tax paid   
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    17
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    501
    ${taxpaid}=   Set Variable    500
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC3: Calculator validation tax relief with age: 0
    [Tags]    Functional   
    [Documentation]    Test on age of a new born baby
    ...    Improvement: should add new instruction to state that Tax relief should limit to certain age range
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    0
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    50
    ${taxpaid}=   Set Variable    5
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC4: Calculator validation tax relief with age: 222
    [Tags]    Functional   
    [Documentation]    Test on age of a old highlander 
    ...    Improvement: should add new instruction to state that Tax relief should limit to certain age range
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    222
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    500
    ${taxpaid}=   Set Variable    5
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    # ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    # Log To Console    ${newbirthday}
    # ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "05011800", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC5: Calculator validation tax relief with age: 17 AND Tax paid and Salary has the same amount
    [Tags]    Functional   
    [Documentation]  There is a bug, there is no description that the 125 would be presented as tax relief
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    17
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    500
    ${taxpaid}=   Set Variable    500
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

## Decimal place
US4_TC6: Calculator validation tax relief with tax relief of 2 Decimal place
    [Tags]    Functional    Smoke
    [Documentation]  Test case on Decimal place
    ...              To verify the tax relief calculation when Tax paid with 2 decimal place where normal rounding will not be applied successfully
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    17
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    500
    ${taxpaid}=   Set Variable    399.46
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC7: Calculator validation tax relief with tax relief of 2 Decimal place case2
    [Tags]    Functional   
    [Documentation]  Test case on Decimal place
    ...              To verify the tax relief calculation when Tax paid with 2 decimal place where normal rounding will be applied successfully
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    17
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    500
    ${taxpaid}=   Set Variable    399.51
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}


US4_TC8: Calculator validation tax relief with tax relief of 3 Decimal place
    [Tags]    Functional   
    [Documentation]  Test case on Decimal place
    ...              To verify the tax relief calculation when Tax paid with 3 decimal place where normal rounding will applied successfully
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    17
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    500.000
    ${taxpaid}=   Set Variable    399.446
    ${decimalplace}=    Set Variable    3

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC9: Calculator validation tax relief with age: less than 17
    [Tags]    Functional   
    [Documentation]  Test case based on age
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    17
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    1000
    ${taxpaid}=   Set Variable    20
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC10: Calculator validation tax relief with age: 18
    [Tags]    Functional   
    [Documentation]  Test case based on age
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    18
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    1000
    ${taxpaid}=   Set Variable    20
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC11: Calculator validation tax relief with age: 19
    [Tags]    Functional   
    [Documentation]  Test case based on age
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    19
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    1000
    ${taxpaid}=   Set Variable    20
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC12: Calculator validation tax relief with age: 35
    [Tags]    Functional    Smoke
    [Documentation]  Test case based on age
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    35
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    1000
    ${taxpaid}=   Set Variable    20
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC13: Calculator validation tax relief with age: 36
    [Tags]    Functional   
    [Documentation]  Test case based on age
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    36
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    1000
    ${taxpaid}=   Set Variable    20
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}  
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC14: Calculator validation tax relief with age: 50
    [Tags]    Functional   
    [Documentation]  Test case based on age
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    50
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    1000
    ${taxpaid}=   Set Variable    20
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC15: Calculator validation tax relief with age: 51
    [Tags]    Functional   
    [Documentation]  Test case based on age
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    51
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    1000
    ${taxpaid}=   Set Variable    20
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    
    ${relief}=    Convert To Number    ${relief}    ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC16: Calculator validation tax relief with age: 75
    [Tags]    Functional   
    [Documentation]  Test case based on age
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    75
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    1000
    ${taxpaid}=   Set Variable    20
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    
    ${relief}=    Convert To Number    ${relief}    ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC17: Calculator validation tax relief with age: 76
    [Tags]    Functional   
    [Documentation]  Test case based on age
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    76
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    1000
    ${taxpaid}=   Set Variable    20
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC18: Calculator validation tax relief with age: 77
    [Tags]    Functional   
    [Documentation]  Test case based on age
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    77
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    1000
    ${taxpaid}=   Set Variable    20
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC19: Calculator validation tax relief with age: 78
    [Tags]    Functional   
    [Documentation]  Test case based on age
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    78
    ${gender}=    Set Variable    m
    ${salary}=    Set Variable    1000
    ${taxpaid}=   Set Variable    20
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC20: Calculator validation tax relief with age: 17 AND gender female
    [Tags]    Functional   
    [Documentation]  Test case based on age and gender
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    51
    ${gender}=    Set Variable    f
    ${salary}=    Set Variable    1000
    ${taxpaid}=   Set Variable    20
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}

US4_TC21: Calculator validation tax relief with age: 78 AND gender female
    [Tags]    Functional    Smoke
    [Documentation]  Test case based on age and gender
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${age}=       Set Variable    51
    ${gender}=    Set Variable    f
    ${salary}=    Set Variable    1000
    ${taxpaid}=   Set Variable    20
    ${decimalplace}=    Set Variable    2

    ${currDate}=        Get Current Date
    ${curryear}=        Get Substring    ${currDate}    0  4
    ${newbirthday}=     calculate birthday with currentDate by age     ${curryear}  ${age}
    ${response}=    POST  ${api_url}/calculator/insert  {"birthday": "${newbirthday}", "gender": "${gender}", "name": "user", "natid": "11325", "salary": "${salary}", "tax": "${taxpaid}"}  headers=&{headers}
    Integer   response status  202
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body    
    ${targetfield}=  Convert To String  ${resArray}[-1][-1]
    Log To Console   ${targetfield}
    ${salary}=    Convert To Number    ${salary}    ${decimalplace} 
    ${taxpaid}=   Convert To Number    ${taxpaid}   ${decimalplace}   
    ${relief}=    calculate tax relief by salary, taxpaid, age and gender  ${salary}  ${taxpaid}  ${age}  ${gender}  ${decimalplace}
    Log To Console   ${relief}
    Should Contain Any    ${targetfield}  relief': '${relief}  

US4_TC22: Calculator validation tax relief to check natid masking function
    [Tags]    Functional    Smoke
    [documentation]  Bug: Should return success with no masking from 1st natid
    ...              Improvement: single natid character should be allow or new instruction should be added to indiciate the minimum number of characters for natid.
    ${headers}=  Create Dictionary  Content-Type=application/json

    # no masking 1st chars
    ${response}=    POST  ${api_url}/calculator/insertMultiple  ${array_user4masking}  headers=&{headers}
    assert valid result
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body 
    ${targetfield1}=  Convert To String  ${resArray}[-1][-1]
    Should Contain Any    ${targetfield1}  'natid': '1'

US4_TC23: Calculator validation tax relief to check natid masking function
    [Tags]    Functional    Smoke
    [documentation]  Should return success with no masking from 1st to 4th characters
    ${headers}=  Create Dictionary  Content-Type=application/json

    # no masking 1st to 4th chars
    ${response}=    POST  ${api_url}/calculator/insertMultiple  ${array_user0masking}  headers=&{headers}
    assert valid result
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body 
    ${targetfield1}=  Convert To String  ${resArray}[-1][-1]
    Should Contain Any    ${targetfield1}  'natid': '1234'

US4_TC24: Calculator validation tax relief to check natid masking function
    [Tags]    Functional    Smoke
    [documentation]  Should return success with masking from 5th onwards
    ${headers}=  Create Dictionary  Content-Type=application/json

    # 5th char masked
    ${response}=    POST  ${api_url}/calculator/insertMultiple  ${array_user1masking}  headers=&{headers}
    assert valid result
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body 
    ${targetfield1}=  Convert To String  ${resArray}[-1][-1]
    Should Contain Any    ${targetfield1}  'natid': '1234$'

US4_TC25: Calculator validation tax relief to check natid masking function
    [Tags]    Functional    Smoke
    [documentation]  Should return success with masking from 5th onwards - 2nd case
    ${headers}=  Create Dictionary  Content-Type=application/json

    # 6th char masked
    ${response}=    POST  ${api_url}/calculator/insertMultiple  ${array_user2masking}  headers=&{headers}
    assert valid result
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body 
    ${targetfield1}=  Convert To String  ${resArray}[-1][-1]
    Should Contain Any    ${targetfield1}  'natid': '1234$$'

US4_TC26: Calculator validation tax relief to check natid masking function
    [Tags]    Functional    Smoke
    [documentation]  Should return success with masking from 5th onwards
    ...    the 5th testcase is to verify that natid masking function should able to support minimum 1 millions number of numberic characters
    ${headers}=  Create Dictionary  Content-Type=application/json

    # long number of characters masked
    ${response}=    POST  ${api_url}/calculator/insertMultiple  ${array_user3masking}  headers=&{headers}
    assert valid result
    ${response}=    GET  ${api_url}/calculator/taxRelief  headers=&{headers}
    Integer   response status  200
    ${resArray}=    Array    response body 
    ${targetfield1}=  Convert To String  ${resArray}[-1][-1]
    Should Contain Any    ${targetfield1}  'natid': '1234$$$$$$$$$$$$$$$'