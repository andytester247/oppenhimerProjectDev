# Prerequisties
- install the python via  https://www.python.org/
- python -m pip install -U pip
- pip install robotframework
- python -m pip install -U pip
- pip install robotframework-selenium2library
- pip install robotframework-seleniumlibrary
- pip install robotframework-requests

> pip list to display the required dependences stated above 

- Download OppenheimerProjectDev.jar from https://github.com/strengthandwill/oppenheimer-project-dev
> java -jar OppenheimerProjectDev.jar

# Dependences
## Packages and versions
| Packages                       | Versions |
| --------                       | --------:|
| robotframework                 | 6.0.1    |
| robotframework-requests        | 0.9.4    |
| robotframework-jsonlibrary     | 0.5      |
| robotframework-seleniumlibrary | 6.0.0    |
| requests                       | 2.28.1   |  
| allure-robotframework          | 2.12.0   |

| WebDrivers | Versions |
| ---------- | -------- |
| Chrome | 108.0.5359.71 |
| Gecko | 0.32.0 |
| Edge | 108.0.1462.54 |

Python - 3.11.1

# How to run testsuite robot file
##### To run each robot test suite individually, you may required to re-run OppenheimerProjectDev.jar per each testsuite.
> robot -d results_CalInsert Tests/CalInsert.robot

> robot -d results_CalTaxRelief Tests/CalTaxRelief.robot

> robot -d results_InsertMultipleMasking Tests/InsertMultipleMasking.robot

> robot -d results_UIportal Tests/UIportal.robot

#####  To run all test suite
> robot -d results Tests/*

#### Merge all output into single output.xml
> rebot -R --xunit mergedoutput.xml results_CalInsert/output.xml results_CalTaxRelief/output.xml results_UIportal/output.xml

# TestResult
Testsuite has completed, and the results are listed in the following folders:
- Results_calInsert, results_CalTaxRelief, results_InsertMultipleMasking, results_UIportal
- results

# Allure Report

# Generate allure report from the recent run Test

# View allure report





