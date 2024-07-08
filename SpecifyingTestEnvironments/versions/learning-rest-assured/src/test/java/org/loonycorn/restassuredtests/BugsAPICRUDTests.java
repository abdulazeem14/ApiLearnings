package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import io.restassured.specification.ResponseSpecification;
import org.loonycorn.restassuredtests.model.BugRequestBody;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class BugsAPICRUDTests extends BaseBugAPITests {

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

    @Test(dependsOnMethods = { "testPOSTCreateBugOne", "testPOSTCreateBugTwo" })
    public void testGETTwoMoreBugsPresent() {

        RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .body("size()", greaterThan(25));
    }


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
}
