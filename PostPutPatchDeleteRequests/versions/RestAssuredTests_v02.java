package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String BUGS_URL = "http://localhost:8090/bugs";

    @Test
    public void testPOSTCreateBug() {
        String bugBodyJson = "{\n" +
                "    \"createdBy\": \"Kim Doe\",\n" +
                "    \"priority\": 2 ,\n" +
                "    \"severity\": \"Critical\",\n" +
                "    \"title\": \"Database Connection Failure\",\n" +
                "    \"completed\": false\n" +
                "}";

        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(bugBodyJson)
                .when()
                    .post(BUGS_URL)
                .then()
                    .statusCode(201)
                    .body("createdBy", equalTo("Kim Doe"),
                            "priority", equalTo(2),
                            "severity", equalTo("Critical"),
                            "title", equalTo("Database Connection Failure"),
                            "completed", equalTo(false)
                    );
    }


    @Test(dependsOnMethods = { "testPOSTCreateBug" })
    public void testGETCreatedBug() {
        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                .when()
                    .get(BUGS_URL)
                .then()
                    .statusCode(200)
                    .body("createdBy", hasItem("Kim Doe"))
                    .body("priority", hasItem(2))
                    .body("severity", hasItem("Critical"))
                    .body("title", hasItem(equalToIgnoringCase("database connection failure")));
    }
}