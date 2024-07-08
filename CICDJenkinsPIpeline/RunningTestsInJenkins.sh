#################################
Setting up the Tests
#################################

# Behind the scenes you should have two modules open on IntelliJ (use the projects with this demo - however you will need to change the code in the main test file)

bugs-api

learning-rest-assured

# Also make sure that you delete the previous integration you had with GitHub so you start afresh

# Delete the "testng.xml" file and uninstall the "Create TestNG XML" plugin - we will set those up as a part of this demo


###############################
# This is just FYI not for recording

# Setting up the second Maven project as a module

# Have the first project with your tests open (learning)

# Make sure the projects are under /Users/loonycorn/IdeaProjects 

# => Place the bugs-api project in the IDEAProjects folder on your machine

# => On IntelliJ Click on File -> New -> Module from existing sources

# => Select the bugs-api project from IDEAProjects

# => Choose "Import module from external model"

# => Choose Maven

# => Import the project as a module

# You can now run your server and tests from the same IntelliJ window

###############################
# Start recording from here

=> Open "bug-api" project in IntelliJ IDEA (use the project provided)
=> Please note that this runs on port 8090

(Show the project structure, and show the 
    "pom.xml", "application.properties"
    "Bug.java" and "BugController.java" files)

# Please note that I have the Maven Surefire plugin to run maven tests

=> Click on the "Run" icon of BugsApiApplication
(Observe in the console tomcat is running in port 8090)

=> Open browser and navigate to http://localhost:8090
(We get the welcome message, its working)


# (Have the tests and project already set up behind the scenes)
=> Open up the learning-rest-assured project

=> Show the BugsApiTests.java file

=> Scrolls and show the contents

=> Contents as below

################################# (V1)

package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.http.ContentType;
import io.restassured.specification.ResponseSpecification;
import org.loonycorn.restassuredtests.model.BugRequestBody;

import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import java.util.List;

import static org.hamcrest.Matchers.*;

public class BugsApiTests {

    @BeforeSuite
    void setup() {
        RestAssured.baseURI = "http://localhost:8080";
        RestAssured.basePath = "bugs";

        RestAssured.requestSpecification = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .build();
    }

    private ResponseSpecification createResponseSpec(BugRequestBody bug) {
        return new ResponseSpecBuilder()
                .expectBody("createdBy", equalTo(bug.getCreatedBy()))
                .expectBody("priority", equalTo(bug.getPriority()))
                .expectBody("severity", equalTo(bug.getSeverity()))
                .expectBody("title", equalToIgnoringCase(bug.getTitle()))
                .expectBody("completed", equalTo(bug.getCompleted()))
                .build();
    }

    @Test
    public void testPOSTCreateBugOne() {
        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 3, "High",
                "Cannot filter by category", false
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


    @Test
    public void testPOSTCreateBugTwo() {
        BugRequestBody bug = new BugRequestBody(
                "Norah Jones", 0, "Critical",
                "Home page does not load", false
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

    @Test(dependsOnMethods = {"testPOSTCreateBugOne", "testPOSTCreateBugTwo"})
    public void testGETRetrieveBugs() {
        RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .body("size()", equalTo(2));
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    public void testPUTUpdateBugOne() {
        // Changed priority, severity, and title
        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 1, "Critical",
                "Homepage hangs", false
        );

        ResponseSpecification responseSpec = createResponseSpec(bug);

        String bugId = RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .extract().path("bugId[0]");

        RestAssured
                .given()
                    .pathParam("bug_id", bugId)
                    .body(bug)
                .when()
                    .put("/{bug_id}")
                .then()
                    .statusCode(200)
                    .spec(responseSpec);
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    public void testPATCHUpdateBugTwo() {
        BugRequestBody bug = new BugRequestBody(
                null, null, null,
                null, true
        );

        String bugId = RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .extract().path("bugId[1]");

        RestAssured
                .given()
                    .pathParam("bug_id", bugId)
                    .body(bug)
                .when()
                    .patch("/{bug_id}")
                .then()
                    .statusCode(200)
                    .body("completed", equalTo(bug.getCompleted()));
    }

    @Test(dependsOnMethods = "testPATCHUpdateBugTwo")
    public void testDELETEAllBugs() {
        List<String> bugIds = RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .extract().path("bugId");

        for (String bugId : bugIds) {
            RestAssured
                    .given()
                        .pathParam("bug_id", bugId)
                    .when()
                        .delete("/{bug_id}")
                    .then()
                        .statusCode(200)
                        .body("bug_id", equalTo(bugId));
        }
    }

}


#################################
# Different ways of running the tests
#################################

=> Right click and select "Run 'BugApiTests'"
(All the tests should pass)

# Lets create a testng.xml file to run the tests
=> Click on "IntelliJ IDEA" > "Preferences" > "Plugins" > "Create TestNG XML" > "Install" from the top menu

=> Right click on the root folder ie "learning-rest-assured" > "Create TestNG XML"

=> Right click on root folder ie "learning-rest-assured" > "Reload from Disk"
(Observes testng.xml file is created)

# Open "testng.xml" file
=> Press "Command" + "Shift" + "Alt" + "L" to format the file
(Observe there are only 2 tests in the suite, this is buggy)

# This plugin will generate proper xml files most of the times but sometimes it may not generate the correct xml file
# We need to manually edit the xml file to include all the tests

=> Paste the below xml suite in "testng.xml" file
(Have just added the additional tests)

#################################
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE suite SYSTEM "http://testng.org/testng-1.0.dtd">
<suite name="All Test Suite">
    <test verbose="2" name="/Users/loonycorn/IdeaProjects/learning-rest-assured">
        <classes>
            <class name="org.loonycorn.restassuredtests.RestAssuredTests">
                <methods>
                    <include name="testPOSTCreateBugOne"/>
                    <include name="testPOSTCreateBugTwo"/>
                    <include name="testGETRetrieveBugs"/>
                    <include name="testPUTUpdateBugOne"/>
                    <include name="testPATCHUpdateBugTwo"/>
                    <include name="testDELETEAllBugs"/>
                </methods>
            </class>
        </classes>
    </test>
</suite>
#################################


=> Right click on the "testng.xml" file > "Run 'testng.xml'"
(Observes all the tests pass)


# Another way to run the tests is to use the "mvn test" command

# Please move your Maven installation to /Users/loonycorn instead of having it in Downloads/. Please make sure you update your PATH variable accordingly


# Open terminal
$ cd /Users/loonycorn/IdeaProjects/learning-rest-assured

# Make sure you have Maven installed (you should already have it installed, we do NOT need to show Maven installation)

$ mvn --version

# Here is where you can get set up with Maven

# Go to

https://maven.apache.org/download.cgi

# Show that this is where you can download the Maven archive (don't actually download it)

# Now go to

https://maven.apache.org/install.html

# Show that here are the instructions to install Maven

# On the terminal

$ nano ~/.zshrc

# Show the JAVA_HOME variable and the PATH variable pointing to Maven



#################################
$ mvn test
(Observes all the tests pass)

$ mvn test -Dsuitefilename="testng.xml"
(Observes all the tests pass)


$ mvn clean install
(Observes all the tests pass)


$ mvn -B -f pom.xml clean test
(We will be using a variation of this command in Jenkins, later)


$ touch run-tests.sh

$ nano run-tests.sh

=> Paste the below command in the file

```
#!/bin/bash

cd /Users/loonycorn/IdeaProjects/learning-rest-assured
mvn test
```

$ chmod +x run-tests.sh

$ ./run-tests.sh

#################################
# Running the Tests in Jenkins
#################################

# Restart the bug-api project in IntelliJ IDEA
=> Open browser and navigate to http://localhost:8080

=> Click on "New Item"

=> Enter item name as "BugsApiTests"

=> Select "Freestyle project" and click "OK"

Description: This project will run the tests for the Bugs API server

=> Scroll down to "Build" section and click on "Add build step" > "Execute shell"

=> Click on "the list of available environment variables" and close the tab

=> Paste the below command in the "Command" text area

```
cd /Users/loonycorn/IdeaProjects/learning-rest-assured
./run-tests.sh
```
=> Click on "Save"

=> Click on "Build Now"

=> Click on #1

=> Click on "Console Output"

(Observe we get an error mvn is not found)

=> Go back to "BugAPITests" from the top left

=> Click on "Configure" and paste the below command in the "Command" text area

```
export PATH="/Users/loonycorn/apache-maven-3.9.6/bin:$PATH"
cd /Users/loonycorn/Downloads/JenkinsIntegration
./run-tests.sh
```

=> Click on "Save"

=> Click on "Build Now"

=> Click on the build number ie (2) > "Console Output"
(Observes all the tests pass!)

# Now go to your project (learning-rest-assured)

# Make some change to your test so it fails i.e. change URL to http://localhost:8091

=> Go back to the BugApiTests project

=> Click on "Build Now"

=> Click on the build number ie (3) > "Console Output"
(This will fail)


# Now go to your project (learning-rest-assured)
# Make the fix to the URL to be correct http://localhost:8090

=> Go back to the BugApiTests project

=> Click on "Build Now"

=> Click on the build number ie (4) > "Console Output"
(This will pass!)

=> Go back to the Jenkins dashboard

=> Hover over each of the column names ie (Status, Last Success, Last failure, etc)

=> Hover over the "Weather" icon

=> Click on "Build History" from the left menu

=> Click on the terminal icon next to any of the builds (on the right)

=> This will take you to the "Console" output of the build










