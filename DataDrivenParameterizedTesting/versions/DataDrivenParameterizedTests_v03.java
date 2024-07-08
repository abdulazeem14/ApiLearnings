package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class DataDrivenParameterizedTests {

    private final String BUGS_URL = "http://localhost:8080/bugs";

    @DataProvider(name = "severityAndTitleContainsQueryParams")
    public Object[][] severityAndTitleContainsQueryParams() {
        return new Object[][] {
                {"low", "error"},
                {"low", "broken"},
                {"medium", "fail"},
                {"high", "timeout"},
                {"critical", "incorrect"}
        };
    }

    @Test(dataProvider = "severityAndTitleContainsQueryParams")
    void testGETRequestBySeverityAndTitleContains(String severity, String titleContains) {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("severity", severity)
                    .queryParam("titleContains", titleContains)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("severity", everyItem(equalTo(severity)))
                    .body("title", everyItem(containsString(titleContains)));
    }


    @DataProvider(name = "priorityAndCompletedQueryParams")
    public Object[][] priorityAndCompletedQueryParams() {
        return new Object[][] {
                {0, true},
                {1, false},
                {2, true},
                {3, false}
        };
    }

    @Test(dataProvider = "priorityAndCompletedQueryParams")
    void testGETRequestByPriorityAndCompleted(Integer priority, Boolean completed) {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("priority", priority)
                    .queryParam("completed", completed)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("priority", everyItem(equalTo(priority)))
                    .body("completed", everyItem(is(completed)));
    }
}
