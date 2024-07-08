-----------------------------------------------
Specifying test environments
-----------------------------------------------

# IMPORTANT: Make sure you run the Bugs API

# Let's start by architecting our tests a little better


-----------------------------------------------
# Makes sure under restassuredtests/model we have BugRequestBody


import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class BugRequestBody {
    private String createdBy;
    private Integer priority;
    private String severity;
    private String title;
    private Boolean completed;
}


# Note the new name of this file BugsAPICRUDTests

# Here is the original file we have to create two bugs and then test that they have been created successfully


package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.http.ContentType;
import io.restassured.specification.ResponseSpecification;
import org.loonycorn.restassuredtests.model.BugRequestBody;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class BugsAPICRUDTests {

    @BeforeSuite
    void setup() {
        RestAssured.baseURI = "http://localhost:8080";
        RestAssured.basePath = "bugs";

        RestAssured.requestSpecification = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .build();
    }

    @Test
    public void testPOSTCreateBugOne() {
        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 3, "High",
                "Cannot filter by category", false
        );

        ResponseSpecification responseSpec = new ResponseSpecBuilder()
                .expectBody("createdBy", equalTo(bug.getCreatedBy()))
                .expectBody("priority", equalTo(bug.getPriority()))
                .expectBody("severity", equalTo(bug.getSeverity()))
                .expectBody("title", equalToIgnoringCase(bug.getTitle()))
                .expectBody("completed", equalTo(bug.getCompleted()))
                .build();

        String bugId = RestAssured
                .given()
                    .body(bug)
                .when()
                    .post()
                .then()
                    .statusCode(201)
                    .spec(responseSpec)
                    .extract().path("bugId");

        System.out.println("Bug ID: " + bugId);

        RestAssured
                .given()
                    .pathParam("bug_id", bugId)
                .when()
                    .get("/{bug_id}")
                .then()
                    .statusCode(200)
                    .spec(responseSpec);
    }

    @Test
    public void testPOSTCreateBugTwo() {

        BugRequestBody bug = new BugRequestBody(
                "Norah Jones", 0, "Critical",
                "Home page does not load", false
        );

        ResponseSpecification responseSpec = new ResponseSpecBuilder()
                .expectBody("createdBy", equalTo(bug.getCreatedBy()))
                .expectBody("priority", equalTo(bug.getPriority()))
                .expectBody("severity", equalTo(bug.getSeverity()))
                .expectBody("title", equalToIgnoringCase(bug.getTitle()))
                .expectBody("completed", equalTo(bug.getCompleted()))
                .build();

        String bugId = RestAssured
                .given()
                    .body(bug)
                .when()
                    .post()
                .then()
                    .statusCode(201)
                    .spec(responseSpec)
                    .extract().path("bugId");

        System.out.println("Bug ID: " + bugId);

        RestAssured
                .given()
                    .pathParam("bug_id", bugId)
                .when()
                    .get("/{bug_id}")
                .then()
                    .statusCode(200)
                    .spec(responseSpec);
    }

    @Test(dependsOnMethods = { "testPOSTCreateBugOne", "testPOSTCreateBugTwo" })
    public void testGETTwoMoreBugsPresent() {

        RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .body("size()", greaterThan(25));
    }
}

# Run the tests and make sure that this works

-----------------------------------------------
# Now we could have different tests for bugs in different files and they would need common set up. We need to have this setup in one place so that it is not repeated in each file. Now we could do this via inheritance or composition. Because we plan to have different tests suites with similar set up it makes sense to use inheritance here.


# Under restassuredtests/ create a new JAva file

BaseBugAPITests.java

# Add this set up code here in this base class

import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.http.ContentType;
import org.testng.annotations.BeforeSuite;

public class BaseBugAPITests {

    @BeforeSuite
    void setup() {
        RestAssured.baseURI = "http://localhost:8080";
        RestAssured.basePath = "bugs";

        RestAssured.requestSpecification = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .build();
    }
}


# Remove the set up code from

BugsAPICRUDTests

# Have this extend the base class

public class BugsAPICRUDTests extends BaseBugAPITests


# Now run the tests and show that things still work


-----------------------------------------------

# Now if you look at the response specification for each bug it is repetitive code, this can be moved into the base class as well. Can be used for bug update requests as well

# Add this to BaseBugAPITests


    protected ResponseSpecification createBugCheckResponseSpec(BugRequestBody bug) {
        return new ResponseSpecBuilder()
                .expectBody("createdBy", equalTo(bug.getCreatedBy()))
                .expectBody("priority", equalTo(bug.getPriority()))
                .expectBody("severity", equalTo(bug.getSeverity()))
                .expectBody("title", equalToIgnoringCase(bug.getTitle()))
                .expectBody("completed", equalTo(bug.getCompleted()))
                .build();
    }


# Get rid of this from the derived class and replace with this

        ResponseSpecification responseSpec = createBugCheckResponseSpec(bug);


# NOTE this has to be done in two methods

# Code now looks like this


public class BugsAPICRUDTests extends BaseBugAPITests {

    @Test
    public void testPOSTCreateBugOne() {
        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 3, "High",
                "Cannot filter by category", false
        );

        ResponseSpecification responseSpec = createBugCheckResponseSpec(bug);

        String bugId = RestAssured
                .given()
                    .body(bug)
                .when()
                    .post()
                .then()
                    .statusCode(201)
                    .spec(responseSpec)
                    .extract().path("bugId");

        System.out.println("Bug ID: " + bugId);

        RestAssured
                .given()
                    .pathParam("bug_id", bugId)
                .when()
                    .get("/{bug_id}")
                .then()
                    .statusCode(200)
                    .spec(responseSpec);
    }

    @Test
    public void testPOSTCreateBugTwo() {

        BugRequestBody bug = new BugRequestBody(
                "Norah Jones", 0, "Critical",
                "Home page does not load", false
        );

        ResponseSpecification responseSpec = createBugCheckResponseSpec(bug);

        String bugId = RestAssured
                .given()
                    .body(bug)
                .when()
                    .post()
                .then()
                    .statusCode(201)
                    .spec(responseSpec)
                    .extract().path("bugId");

        System.out.println("Bug ID: " + bugId);

        RestAssured
                .given()
                    .pathParam("bug_id", bugId)
                .when()
                    .get("/{bug_id}")
                .then()
                    .statusCode(200)
                    .spec(responseSpec);
    }

    @Test(dependsOnMethods = { "testPOSTCreateBugOne", "testPOSTCreateBugTwo" })
    public void testGETTwoMoreBugsPresent() {

        RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .body("size()", greaterThan(25));
    }

}

# Run the tests and show


-----------------------------------------------

# We can abstract away even more into the base class. The way we create bugs, that is going to remain the same. The derived classes need not write the same logic over and over again to create a bug and test that it has been created successfully. We will move that up into the base class

# Add this to BaseBugAPITests


    protected Response createAndValidateBug(BugRequestBody bug) {

        ResponseSpecification responseSpec = createBugCheckResponseSpec(bug);

        Response response = RestAssured
                .given()
                    .body(bug)
                .when()
                    .post()
                .then()
                    .statusCode(201)
                    .spec(responseSpec)
                    .extract().response();

        String bugId = response.jsonPath().getString("bugId");

        System.out.println("Bug ID: " + bugId);

        RestAssured
                .given()
                    .pathParam("bug_id", bugId)
                .when()
                    .get("/{bug_id}")
                .then()
                    .statusCode(200)
                    .spec(responseSpec);

        return response;
    }


# Notice that it returns the response from create, this is so that the derived class can perform additional tests if it needs to

# In BugsAPICRUDTests

# Replace the create requests and checks with just this one line


        createAndValidateBug(bug);

# IMPORTANT: Need to do this in two places

# The two methods should now look like this



    @Test
    public void testPOSTCreateBugOne() {
        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 3, "High",
                "Cannot filter by category", false
        );

        createAndValidateBug(bug);
    }

    @Test
    public void testPOSTCreateBugTwo() {

        BugRequestBody bug = new BugRequestBody(
                "Norah Jones", 0, "Critical",
                "Home page does not load", false
        );

        createAndValidateBug(bug);
    }


# Run and show

# In the base class, make some tweak to the checks in teh bug (just change the propery accessed from the body in the ResponseSpecBuilder e.g. "created" instead of "createdBy")

# Run and show the failure

# Change it back

-----------------------------------------------

# Now add more tests in the derived class (to both methods)


        Response response = createAndValidateBug(bug);

        assertThat(response.jsonPath().get("createdOn"), notNullValue());
        assertThat(response.jsonPath().get("updatedOn"), notNullValue());


# Code looks like this:


    @Test
    public void testPOSTCreateBugOne() {
        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 3, "High",
                "Cannot filter by category", false
        );

        Response response = createAndValidateBug(bug);

        assertThat(response.jsonPath().get("createdOn"), notNullValue());
        assertThat(response.jsonPath().get("updatedOn"), notNullValue());
    }

    @Test
    public void testPOSTCreateBugTwo() {

        BugRequestBody bug = new BugRequestBody(
                "Norah Jones", 0, "Critical",
                "Home page does not load", false
        );

        Response response = createAndValidateBug(bug);

        assertThat(response.jsonPath().get("createdOn"), notNullValue());
        assertThat(response.jsonPath().get("updatedOn"), notNullValue());
    }


# Now run and everything should pass


-----------------------------------------------
# Now let's add something to update a bug

# Add this to the base class BaseBugAPITests



    protected Response updateAndValidateBug(String bugId, BugRequestBody bug) {
        System.out.println("Bug ID to update: " + bugId);

        ResponseSpecification responseSpec = createBugCheckResponseSpec(bug);

        Response response = RestAssured
                .given()
                    .pathParam("bug_id", bugId)
                    .body(bug)
                .when()
                    .put("/{bug_id}")
                .then()
                    .statusCode(200)
                    .spec(responseSpec)
                    .extract().response();

        RestAssured
                .given()
                    .pathParam("bug_id", bugId)
                .when()
                    .get("/{bug_id}")
                .then()
                    .statusCode(200)
                    .spec(responseSpec);

        return response;
    }


# Add this to the derived class


    @Test
    public void testPOSTUpdateBug() {

        String bugId = RestAssured
                .get()
                .then()
                .statusCode(200)
                .extract().path("[12].bugId");

        BugRequestBody bug = new BugRequestBody(
                "Marty Schwartz", 4, "Low",
                "Cart page is not pretty", false
        );

        Response response = updateAndValidateBug(bugId, bug);

        assertThat(response.jsonPath().get("createdOn"), notNullValue());
        assertThat(response.jsonPath().get("updatedOn"), notNullValue());
    }


# run the test and show it passes

# Go to

http://localhost:8080/bugs

# Search for Marty and you will find a bug from MArty in there



















































