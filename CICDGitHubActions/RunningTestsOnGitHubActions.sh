#################################
Setting up GitHub Actions
#################################
# https://medium.com/anarocktech/running-tests-made-easy-with-rest-assured-and-github-actions-ebfc0bfff084

=> Goto "github.com"

=> Click on "bugs-api-tests-repo" repository

=> Click on "Actions" from the top navbar

=> Click "New Workflow"

=> Search for "Java" and select "Java with Maven"
=> Click "Configure" button
(Observe most of the code is already written for us)

# Let's make a few changes

=> Rename to "bugs-api-tests-workflow.yml"

=> Change the name of the workflow 

"Java CI with Maven for Bug API tests"

=> Remove the build on pull_request (these lines below)

 pull_request:
    branches: [ "master" ]


# We will delete the "Build with Maven" and "Update dependency graph" steps as we don't need them.
# Replace with the below step we used for Jenkins pipeline.

- name: Test Execution
      run: mvn -B -f pom.xml clean test

# Make sure it is aligned correctly


=> Click "Commit changes"

= Show the file under .github -> workflows -> actions


################################# (V1)
Finally, the "bugs-api-tests-workflow.yml" file should look like this:     

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


#################################

=> Click "Commit changes", commit to the master branch

=> Click on "Actions" from the top navbar

=> Notice that the commit of the workflow file has kickstarted the build

=> Click through and show the build (it may have already completed)

=> Expand all the steps and observe the logs

=> Important: Expand the "Test Execution" step and observe the test results
(Observe that the tests failed - and the error seems to be "Connection refused")


# This is happening because out api is running in local machine and github actions cannot access it.

#################################
# https://stackoverflow.com/questions/73017353/how-to-bypass-ngrok-browser-warning

=> Now we already have the ngrok agent running

=> Go to "ngrok.com" -> endpoints and show that it is up

=> In another tab goto "https://<some_id>.ngrok-free.app"
(Observe we get a initial page saying "ngrok")

# In terminal (-k is to skip SSL certificate verification)
$ curl -k https://<some_id>.ngrok-free.app/bugs

# Sometimes it gives and HTML page
# Does not happen all the time, but sometimes.

# Its always better to add the header to skip the browser warning.

# On the terminal
$ curl -k -H "ngrok-skip-browser-warning: true" https://<some_id>.ngrok-free.app/bugs

# This shoud give us the expected response.



################################# 

=> Now on IntelliJ

=> Select "Git" -> "Pull" from the menu bar on top - to sync up the changes we made on the server

=> Notice we have .github folder 

=> Expand it, open the bugs-api-tests-workflow.yml file and show


=> Go back to the BugsApiTests.java file and replace with the below code
# Have changed the url and added the header to skip the browser warning.

# Just need to do this in one place


    @BeforeSuite
    void setup() {
        RestAssured.baseURI = "https://<some_id>.ngrok-free.app/";
        RestAssured.basePath = "bugs";

        RestAssured.requestSpecification = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .addHeader("ngrok-skip-browser-warning", "true")
                .build();
    }





#################################

=> Click on "Git" -> "Commit"

Commit message: Updated the url and added header to skip the browser warning

=> Click "Commit and push"

=> Go back to the repository in the browser

=> Click on "Actions" from the top navbar

=> Click on the recent workflow run -> "build"

=> Expand all the steps and observe the logs

=> Important: Expand the "Test Execution" step and observe the test results
(Observe now we can see the test results)

# If we need we can manually trigger the workflow by clicking "Re-run all jobs"












