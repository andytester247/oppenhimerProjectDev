*** Settings ***
Library    REST
Library    Collections
Library    String
Library    OperatingSystem
Library    SeleniumLibrary
Library    DateTime
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
    # Log To Console    TESTtaxrelief:${taxrelief}
    ${taxrelief}=    Convert To String    ${taxrelief}
    ${Ptax}=    Evaluate    "${taxrelief}".split(".")
    # Log To Console    TESTTEST-Ptax1:${Ptax[0]}
    ${Ptax[1]}=    Get Substring    ${Ptax[1]}     0     ${decimalplace}
    # Log To Console    TESTTEST-Ptax2:${Ptax[1]}
    ${newtaxrelief}=    Catenate  SEPARATOR=.  ${Ptax[0]}  ${Ptax[1]}
    IF    ${Ptax[1]} < 5
        ${decimalplace}=    Evaluate  ${decimalplace} - 1
    END
    ${taxrelief}=    Convert To Number    ${newtaxrelief}    ${decimalplace}
    # Log To Console    TESTTEST-FINALPtax:${taxrelief}    

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

    # Log To Console    TESTFINAL-FINALPtax:${taxrelief}

    RETURN     ${taxrelief}

*** Test Cases ***
Calculator validation tax relief with age: 17 AND Tax paid more than Salary by 1 dollar
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

Calculator validation tax relief with age: 17 AND Salary more than Tax paid by 1 dollar
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

Calculator validation tax relief with age: 17 AND Tax paid and Salary has the same amount
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
Calculator validation tax relief with tax relief of 2 Decimal place
    [Documentation]  Test case on Decimal place
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

Calculator validation tax relief with tax relief of 2 Decimal place case2
    [Documentation]  Test case on Decimal place
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


Calculator validation tax relief with tax relief of 3 Decimal place
    [Documentation]  Test case on Decimal place
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

Calculator validation tax relief with age: less than 17
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

Calculator validation tax relief with age: 18
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

Calculator validation tax relief with age: 19
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

Calculator validation tax relief with age: 35
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

Calculator validation tax relief with age: 36
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

Calculator validation tax relief with age: 50
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

Calculator validation tax relief with age: 51
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

Calculator validation tax relief with age: 75
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

Calculator validation tax relief with age: 76
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

Calculator validation tax relief with age: 77
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

Calculator validation tax relief with age: 78
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

Calculator validation tax relief with age: 17 AND gender female
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

Calculator validation tax relief with age: 78 AND gender female
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