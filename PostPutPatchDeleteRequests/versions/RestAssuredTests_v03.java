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

        String bugId = RestAssured
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
                            "description", equalTo(false)
                    )
                    .extract().path("bugId");

        System.out.println("Bug ID: " + bugId);
        
        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .baseUri(BUGS_URL)
                    .pathParam("bug_id", bugId)
                .when()
                    .get("/{bug_id}")
                .then()
                    .statusCode(200)
                    .body("createdBy", equalTo("Kim Doe"))
                    .body("priority", equalTo(2))
                    .body("severity", equalTo("Critical"))
                    .body("title", equalToIgnoringCase("database connection failure"))
                    .body("completed", equalTo(false));

    }

}