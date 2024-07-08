package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.authentication.BasicAuthScheme;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.http.ContentType;
import io.restassured.specification.RequestSpecification;
import io.restassured.specification.ResponseSpecification;
import org.loonycorn.restassuredtests.model.BugRequestBody;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredConfigurationTests {

    @BeforeSuite
    void setup() {
        RestAssured.baseURI = "http://localhost:8080";
        RestAssured.basePath = "bugs";

        BasicAuthScheme scheme = new BasicAuthScheme();
        scheme.setUserName("fakeuser");
        scheme.setPassword("fakepassword");

        RestAssured.authentication = scheme;

        RestAssured.requestSpecification = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .setAccept(ContentType.JSON)
                .addHeader("Cookie", "name=value; sessionid=123456789")
                .addHeader("Cache-Control", "no-cache")
                .addHeader("Referer", "https://example.com/previous-page")
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
