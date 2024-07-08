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

import static org.hamcrest.Matchers.*;

public class BaseBugAPITests {

    @BeforeSuite
    void setup() {
        RestAssured.baseURI = "http://localhost:8080";
        RestAssured.basePath = "bugs";

        RestAssured.requestSpecification = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .build();
    }

    protected ResponseSpecification createBugCheckResponseSpec(BugRequestBody bug) {
        return new ResponseSpecBuilder()
                .expectBody("createdBy", equalTo(bug.getCreatedBy()))
                .expectBody("priority", equalTo(bug.getPriority()))
                .expectBody("severity", equalTo(bug.getSeverity()))
                .expectBody("title", equalToIgnoringCase(bug.getTitle()))
                .expectBody("completed", equalTo(bug.getCompleted()))
                .build();
    }


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
}
