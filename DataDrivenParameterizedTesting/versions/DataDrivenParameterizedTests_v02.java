package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class DataDrivenParameterizedTests {

    private final String BUGS_URL = "http://localhost:8080/bugs";

    public Object[][] createdByQueryParams() {
        return new Object[][] {
                {"Jane"}, {"Williams"}, {"Brown"}, {"Mike"}
        };
    }

    @Test(dataProvider = "createdByQueryParams")
    void testGETRequestCreatedByContains(String createdByContains) {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("createdByContains", createdByContains)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("createdBy", everyItem(containsString(createdByContains)));
    }

    @DataProvider(name = "priorityQueryParams")
    public Object[][] priorityQueryParams() {
        return new Object[][] {
                {0}, {1}, {2}, {3}
        };
    }

    @Test(dataProvider = "priorityQueryParams")
    void testGETRequestByPriority(Integer priority) {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("priority", priority)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("priority", everyItem(equalTo(priority)));
    }


    @DataProvider(name = "severityQueryParams")
    public Object[][] severityQueryParams() {
        return new Object[][] {
                {"low"}, {"medium"}, {"high"}, {"critical"}
        };
    }

    @Test(dataProvider = "severityQueryParams")
    void testGETRequestBySeverity(String severity) {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("severity", severity)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("severity", everyItem(equalTo(severity)));
    }

    @DataProvider(name = "completedQueryParams")
    public Object[][] completedQueryParams() {
        return new Object[][] {
                {true}, {false}
        };
    }

    @Test(dataProvider = "completedQueryParams")
    void testGETRequestByCompleted(Boolean completed) {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("completed", completed)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("completed", everyItem(is(completed)));
    }

    @DataProvider(name = "titleContainsQueryParams")
    public Object[][] titleContainsQueryParams() {
        return new Object[][] {
                {"error"}, {"fail"}, {"timeout"}, {"incorrect"}
        };
    }

    @Test(dataProvider = "titleContainsQueryParams")
    void testGETRequestTitleContains(String titleContains) {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("titleContains", titleContains)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("title", everyItem(containsString(titleContains)));
    }

}
