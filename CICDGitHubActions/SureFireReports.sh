#################################
Generating SureFire Reports
################################# (V3)

=> Edit this file on IntelliJ

=> Open "bugs-api-tests-workflow.yml" file 
# Replace with the below code

name: Java CI with Maven for Bug API tests

on:
  push:
    branches: [ "master" ]

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: maven
    - name: Test Execution
      run: mvn -B -f pom.xml clean test
    - name: Get List of Files
      run: ls -a
    - name: What is in the target folder
      run: ls -a target
    - name: SureFire Reports
      uses: actions/upload-artifact@v2
      with:
        name: test-results
        path: target/surefire-reports


#################################

=> Git -> "Commit"

Message: Create SureFire reports

=> "Commit and Push"

=> Click on "Actions" from the top navbar

=> Click on the recent workflow run -> "build"

=> Expand all the steps and observe the logs        

=> Click on "Summary" from the left pane

=> Scroll down and download the "test-results" artifact

=> Extract and open "test-results.zip" file
 
=> Open and show "index.html" and click on each link of info






















