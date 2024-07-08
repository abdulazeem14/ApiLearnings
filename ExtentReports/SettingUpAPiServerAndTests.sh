#################################
Setting up ExtentReports
#################################

# Behind the scenes you should have two modules open on IntelliJ

bugs-api

learning-extent-reports
###############################

# Have the first project with your tests open (learning-extent-reports)

# Make sure the projects are under /Users/loonycorn/IdeaProjects 

=> Place the bugs-api project in the IDEAProjects folder on your machine

=> On IntelliJ Click on File -> New -> Module from existing sources

=> Select the bugs-api project from IDEAProjects

=> Choose "Import module from external model"

=> Choose Maven

=> Import the project as a module
###############################

=> Open "bug-api" project in IntelliJ IDEA
=> Please note that this runs on port 8090

(Show the project structure, and show the 
    "pom.xml", "application.properties", "Bug.java" 
    and "BugController.java" files)

=> Click on the "Run" icon of BugsApiApplication
(Observe in the console tomcat is running in port 8090)


###############################

=> Go to this URL, scroll and show

https://www.extentreports.com/

=> Click on "Docs" -> "Version 5" at the top right

=> Show the Maven artifact that we have to add


=> Open up the learning-extent-reports project (the START version)

=> Open the "pom.xml" file, show the contents of the file

=> and add the following dependencies

<dependency>
    <groupId>com.aventstack</groupId>
    <artifactId>extentreports</artifactId>
    <version>5.1.1</version>
</dependency>

=> Reload Maven by right clicking on the project and selecting "Maven" -> "Reload Project"

=> Open the "testng.xml" file, show the contents of the file

=> Show the BugsApiTests.java file

###############################

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
        RestAssured.baseURI = "http://localhost:8090";
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

        RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .body("size()", equalTo(0));
    }

}


###############################

=> Right click and select "Run 'BugApiTests'"
(All the tests should pass)