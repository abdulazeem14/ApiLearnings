#################################
Integrating Jenkins with Git
#################################

# In order to integrate IntelliJ with git you need to have git installed on your local machine

# On the terminal

git --version

# We already have git installed

# Show we can get git

https://git-scm.com/

# Go to "Downloads"

# Click on each of the platforms and show instructions

MacOS

Windows

Linux

# Now head over to 

https://github.com/


=> Login to GitHub as loonytest (We need this for authentication using IntelliJ IDEA)


# Open IntelliJ IDEA having project "learning-rest-assured". 

# IMPORTANT: Make sure you have learning-rest-assured selected since both projects are open in the same intelliJ window

=> Click on "IntelliJ IDEA" -> "Preferences" -> "Plugins" -> "Browse repositories" -> "GitHub"
(Observe that "GitHub" plugin is already installed)

=> Click on "IntelliJ IDEA" -> "Preferences" -> "Version Control" -> "GitHub" -> "Add account" -> "Login via GitHub" -> "OK" -> "Apply" -> "OK"

=> Click on "IntelliJ IDEA" -> "VCS" -> "Share project on GitHub"

Repository Name: bugs-api-tests-repo
[UNTICK] Private
Remote: origin
Description: This repo contains tests for the Bugs API server

=> Click on "Share"

Initial message: Initial commit of tests for the Bugs API server


=> Click on "Add"

=> Go to GitHub and verify that the repository is created

=> Click and show the 

BugsApiTests.java
pom.xml
testng.xml
run-tests.sh



#################################

# In Jenkins
=> In Jenkins, go to "Manage Jenkins" -> "Manage Plugins" -> "Installed" ->

=> Search for "GitHub"
(In our case, it was already installed, we can see it in "Installed" tab)


# https://stackoverflow.com/questions/45205024/maven-project-option-is-not-showing-in-jenkins-under-new-item-section-latest
=> Click on "Manage Jenkins" > "Plugins" > "Available" > "Maven Integration" > "Install"
(Restart Jenkins - click on the checkbox)


# We will use Maven Project insted of Freestyle Project, so that we can use maven without any issues

(We may need to provide the path of Maven in Jenkins)

=> In Jenkins Dashboard  -> "Manage Jenkins" -> "Tools" -> "Maven installations" -> "Add Maven" 

=> Uncheck "Install Automatically"

Name: maven
MAVEN_HOME: /Users/loonycorn/apache-maven-3.9.6

=> Click on "Apply" -> "Save"

#################################

=> Click on "New Item" -> "BugsApiTestsMaven" -> "Maven Project" -> "OK"

=> Click on "BugsApiTestsMaven" -> "Configure" -> "Source Code Management" -> "Git" 

Description: This project will run the tests for the Bugs API server


(Get this from GitHub -> "Code" -> "HTTPS" -> "Copy" -> "Paste" here)
Repository URL: https://github.com/loonytest/bugs-api-tests-repo.git

# No credentials needed because this is a public repo

=> Scroll to "Branches to build" -> "Branch Specifier" -> "*/master"
(In our case it is master, but in real time it can be any branch)

=> Click on "Build Triggers" 
[UNTICK] "Build whenever a SNAPSHOT dependency is built"
(leave everything unticked here since we are building manually)


=> Click on "Build Environment" -> "Delete workspace before build starts"

=> Click on "Build"
Goals: clean test
Root POM: pom.xml

=> Click "Apply" -> "Save"

=> Click on "Build Now"
(Observe all the test are successful)

=> Click through and show the bug results
=> Show that all the tests have passed

# Now let's get a test to fail, add a bug using curl


curl -X POST \
  http://localhost:8090/bugs \
  -H 'Content-Type: application/json' \
  -d '{
    "createdBy": "Jack Farley",
    "priority": 3,
    "title": "Page does not render correctly",
    "completed": false
}' | jq



=> Goto "http://localhost:8090/bugs"
(Observe there is one bug present if we run the test again, the tests will fails)

# In Jenkins
=> Click "Build Now"
(Observe that the tests are failing)

=> Click through and show that only one test failed testGETRetrieveBugs, other tests would have been skipped

=> Click through and show the error

# 1 expectation failed.
# JSON path size() doesn't match.
# Expected: <2>
#   Actual: <3>


#################################

=> In IntelliJ IDEA, open "BugsApiTests" -> "src" -> "test" -> "java" -> "com.loonycorn" -> "BugsApiTests" -> "BugsApiTests.java"
=> Add a new test case to create a third bug


    @Test
    public void testPOSTCreateBugThree() {
        BugRequestBody bug = new BugRequestBody(
                "Mohamed Ali", 1, "High",
                "Cart is glitchy", false
        );

        ResponseSpecification responseSpec = createResponseSpec(bug);

        RestAssured
                .given()
                .body(bug)
                .when()
                .post()
                .then()
                .statusCode(201)
                .spec(responseSpec);
    }


# Also update the testRetrieveBugs test

    @Test(dependsOnMethods = {"testPOSTCreateBugOne", "testPOSTCreateBugTwo", "testPOSTCreateBugThree"})
    public void testGETRetrieveBugs() {
        RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .body("size()", equalTo(3));
    }


# Update the testng.xml file with the new bug as well

                    <include name="testPOSTCreateBugThree"/>



# In Jenkins
=> Click "Build Now"
(Observe that the tests will still fail)

=> IMPORTANT: Note that the extra test is NOT running yet

=> This is because we have not committed the changes to GitHub, they are only on our local machine. This proves that we are running the tests from GitHub

# Back to IntelliJ

=> Click on "Git" -> "Commit"

Commit Message: Added additional test to create a new bug

=> Click on "Commit and Push"

=> Click on "Push"

loonycorn

loony.test.001@gmail.com

=> Go back to GitHub and verify that the changes are pushed

=> click on 2 commits on the top right of the repo

=> Click on the last commit and show the diff for the BugsApiTests file


#################################

# IMPORTANT Restart the bug-api project in IntelliJ IDEA

=> In Jenkins -> "BugsApiTestsMaven" -> "Build Now"
(Observe that the tests are successful, as the new test case is pulled from GitHub)

=> Click through and show that all tests pass (the new test is included as well)

=> Run "Build Now" again
(Observe that the tests are successful)

=> Goto "http://localhost:8090/bugs"
(Observe that there are no bugs present)



#################################
Scheduling Jenkins Jobs
#################################
# https://crontab.guru/

# In Jenkins
=> Click on "BugsApiTestsMaven" -> "Configure"

=> Click "Build Triggers"
[TICK] Build periodically

* * * * * 
(Run the job every minute)

=> Click "Apply" -> "Save"
(Observe the job is running every minute)
# Wait for about 5 minutes

=> Go back to "Configure"
[UNTICK] Build periodically

=> Click "Apply" -> "Save"

#################################