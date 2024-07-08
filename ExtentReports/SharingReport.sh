################################
Sharing the Extent Report
################################

# Since we have already setup or GitHub action in our previous demos, we can now share the Extent Report using email.

# Behind the scenes

# Delete all the reports except 1 from the reports/ folder



################################

=> Show the ngrok.com website and log in and show that we have no endpoints (start afresh)

=> On the terminal

$ ngrok --version

$ ngrok http http://localhost:8090


=> On ngrok.com, show that we have an endpoint. 

=> Click on the endpoint and show the welcome message


################################


# IMPORTANT: Recreate the GitHub repository bugs-api-tests-repo (start with empty)

=> Go to github.com and show the empty repository


=> Go to Intellij -> Preferences -> Version Control -> GitHub and show that loonytest is connected here
(From the previous demo)

=> Go to the Java file

# BugsApiTests.java
# Change the code in the setup() function to point to the ngrok server


        RestAssured.baseURI = "https://fc06-49-205-138-49.ngrok-free.app/";
        RestAssured.basePath = "bugs";

        RestAssured.requestSpecification = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .addHeader("ngrok-skip-browser-warning", "true")
                .build();


=> Go to the testng.xml file and show


=> Click on "IntelliJ IDEA" -> "VCS" -> "Share project on GitHub"


Repository Name: bugs-api-tests-repo
[UNTICK] Private
Remote: origin
Description: This repo contains tests for the Bugs API server

=> IMPORTANT: Make sure to NOT check in the target/ folder


=> Click on "Share"

Initial message: Initial commit of tests for the Bugs API server


=> Click on "Add"

=> Go to GitHub and verify that the repository is created

=> Click and show the 

BugsApiTests.java
pom.xml
testng.xml


################################
=> Go to github.com

=> Click on "bugs-api-tests-repo" repository

=> Click on "Settings" -> "Secrets & Variables" -> "Actions"
(Show the secrets that we have added in the previous demo)

=> Click on "Actions" from the top navbar

=> Click "New Workflow"

=> Search for "Java" and select "Java with Maven"
=> Click "Configure" button
(Observe most of the code is already written for us)

# Let's make a few changes

=> Rename to "bugs-api-tests-workflow.yml"

# bugs-api-tests-workflow.yml
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
    - name: Find latest modified report
      id: find-latest-report
      run: |
        latest_report=$(ls -t reports/* | head -n1)
        echo "::set-output name=latest_report::$latest_report"
    - name: Upload Latest Modified Report
      uses: actions/upload-artifact@v2
      with:
        name: latest-report
        path: ${{ steps.find-latest-report.outputs.latest_report }}
    - name: Send Email
      uses: dawidd6/action-send-mail@v3
      with:
        server_address: ${{ secrets.EMAIL_SERVER_ADDRESS }}
        server_port: ${{ secrets.EMAIL_SERVER_PORT }}
        secure: true
        username: ${{ secrets.EMAIL_ADDRESS }}
        password: ${{ secrets.EMAIL_PASSWORD }}
        subject: Github Actions job result
        to: cloud.user@loonycorn.com
        from: Loonycorn
        body: All the tests for ${{github.repository}} are completed!
        attachments: ${{ steps.find-latest-report.outputs.latest_report }}



=> Click on "Commit changes"

=> Click on "Actions" from the top navbar

=> Click on the recent workflow run -> "build"

=> Expand all the steps and observe the logs

=> Go to the email and check the email and open the attachment

