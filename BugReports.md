
# Bug reports
TOC

## Summary: Should not return success when insert api call with missing/empty/invalid/Bigcapped gender info from the person detail
-   Description: a post request made for calculator insert api with a JSON content in the following scenarios
    -   when gender is missing, not part of the JSON
    -   when gender is part of the JSON but empty content
    -   when gender info is invalid e.g any other chars than m or f
    -   when gender character is valid but in capped
-   Actual Test Result: return 202
-   Expected result: 500 Internal Server
-   Step to reproduce: 
    -   Prerequistie: 
        - Download OppenheimerProjectDev.jar from https://github.com/strengthandwill/oppenheimer-project-dev
        > java -jar OppenheimerProjectDev.jar
    -   You may use curl command/ or swagger ui (from http://localhost:8080/swagger-ui.html#/calculator-controller/insertPersonUsingPOST_1  /calculator/insert )
        > curl -X POST "http://localhost:8080/calculator/insert" -H "accept: */*" -H "Content-Type: application/json" -d "{ \"birthday\": \"11121988\", \"name\": \"user\", \"natid\": \"12345\", \"salary\": \"1000\", \"tax\": \"80\"}"
        -   as for empty content of gender Senario:
            -   {"birthday": "08051984", "gender": "", "name": "mandy", "natid": "1123", "salary": "1000", "tax": "80"}
        -   as for invalid value of gender Senario:
            -   {"birthday": "08051984", "gender": "g", "name": "mandy", "natid": "1123", "salary": "1000", "tax": "80"}
    -   Expect success code of 202

-   business impact: this will lead to calculator/taxRelief will encounter error 500 due to missing gender information.
-   suggestion: add check to ensure gender should be included
----------------------------------------------

## Summary: Should not return success when insert api call with negative value of both taxPaid and Salary info from the person detail
-   Description: a post request made for calculator insert api with a JSON content in the following scenarios
    -   where Salary value is negative
    -   where tax  paid valus is negative
-   Actual Test Result: return 202
-   Expected result: 500 Internal Server
-   Step to reproduce: 
    -   Prerequistie: 
        - Download OppenheimerProjectDev.jar from https://github.com/strengthandwill/oppenheimer-project-dev
        > java -jar OppenheimerProjectDev.jar
    -   You may use curl command/ or swagger ui (from http://localhost:8080/swagger-ui.html#/calculator-controller/insertPersonUsingPOST_1  /calculator/insert )
        > curl -X POST "http://localhost:8080/calculator/insert" -H "accept: */*" -H "Content-Type: application/json" -d "{ \"birthday\": \"11121988\", \"name\": \"user\", \"natid\": \"12345\", \"gender\": \"f\" \"salary\": \"-1000\", \"tax\": \"80\"}"
        - as for tax:
        > curl -X POST "http://localhost:8080/calculator/insert" -H "accept: */*" -H "Content-Type: application/json" -d "{ \"birthday\": \"11121988\", \"name\": \"user\", \"natid\": \"12345\", \"gender\": \"f\" \"salary\": \"1000\", \"tax\": \"-80\"}"
    -   Expect success code of 202

-   business impact: this will lead to calculator/taxRelief will encounter inaccurate tax Relief due to the negative Salary information.
-   suggestion: add checks to the function to ensure Salary or/and Tax paid is positive value
----------------------------------------------
## Summary: Should not return success when insert api call with empty value on natid or/and name info from the person detail
-   Description: a post request made for calculator insert api with a JSON content in the following scenarios
    -   where name value is part of the JSON but empty character
    -   where natid value is part of the JSON but empty character
-   Actual Test Result: return 202
-   Expected result: 500 Internal Server
-   Step to reproduce: 
    -   Prerequistie: 
        - Download OppenheimerProjectDev.jar from https://github.com/strengthandwill/oppenheimer-project-dev
        > java -jar OppenheimerProjectDev.jar
    -   You may use curl command/ or swagger ui (from http://localhost:8080/swagger-ui.html#/calculator-controller/insertPersonUsingPOST_1  /calculator/insert )
        > curl -X POST "http://localhost:8080/calculator/insert" -H "accept: */*" -H "Content-Type: application/json" -d "{ \"birthday\": \"11121988\", \"name\": \"\", \"natid\": \"12345\", \"gender\": \"f\" \"salary\": \"1000\", \"tax\": \"80\"}"
        - as for empty natid:
        > curl -X POST "http://localhost:8080/calculator/insert" -H "accept: */*" -H "Content-Type: application/json" -d "{ \"birthday\": \"11121988\", \"name\": \"user\", \"natid\": \"\", \"gender\": \"f\" \"salary\": \"1000\", \"tax\": \"80\"}"
    -   Expect success code of 202

-   business impact: although it did not affect other api call, the user would have problem when attempt to do search by name or natid, 
-   suggestion: add checks to the function to ensure the number of characters for name/natid should be more than 1.
----------------------------------------------
## Summary: There is not AC stated: Should return any tax relief when the amount of tax paid and salary are the same
-   Description: a post request made for Tax Relief when both tax paid and salary are the same amount
-   Actual Test Result: return 202, tax Relief: 125
-   Expected result: N/A (more Query is required)
-   Step to reproduce: 
    -   Prerequistie: 
        - Download OppenheimerProjectDev.jar from https://github.com/strengthandwill/oppenheimer-project-dev
        > java -jar OppenheimerProjectDev.jar
    -   You may use curl command/ or swagger ui : for tax relief api
    -   Expect success code of 202, tax relief: 125

-   business impact: incorrect amount to be tax relief, need to check with stakeholder is this AC is valid or not.
-   suggestion: N/A
