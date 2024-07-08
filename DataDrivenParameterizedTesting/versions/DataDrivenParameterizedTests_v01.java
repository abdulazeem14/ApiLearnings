package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class DataDrivenParameterizedTests {

    private final String BUGS_URL = "http://localhost:8080/bugs";

    @Test
    void testGETRequest() {
        RestAssured
                .get(BUGS_URL)
                .then()
                .statusCode(200)
                .body("size()", equalTo(25));
    }

    @Test
    void testGETRequestCreatedByContains() {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("createdByContains", "Jane")
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("createdBy", everyItem(containsString("Jane")));

        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("createdByContains", "Williams")
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("createdBy", everyItem(containsString("Williams")));

    }

    @Test
    void testGETRequestByPriority() {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("priority", 2)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("priority", everyItem(equalTo(2)));

        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("priority", 0)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("priority", everyItem(equalTo(0)));

    }

    @Test
    void testGETRequestBySeverity() {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("severity", "high")
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("severity", everyItem(equalTo("high")));
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("severity", "critical")
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("severity", everyItem(equalTo("critical")));
    }

    @Test
    void testGETRequestByCompletedStatus() {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("completed", true)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("completed", everyItem(is(true)));
    }

    @Test
    void testGETRequestTitleContains() {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("titleContains", "error")
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("title", everyItem(containsString("error")));
    }

    @Test
    void testGETRequestMultipleFilters() {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("severity", "medium")
                    .queryParam("completed", false)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("severity", everyItem(equalTo("medium")))
                    .body("completed", everyItem(is(false)));
    }

}
