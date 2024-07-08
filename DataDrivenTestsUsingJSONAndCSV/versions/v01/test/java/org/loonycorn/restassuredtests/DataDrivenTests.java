package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.loonycorn.restassuredtests.utils.FileUtil;
import org.testng.annotations.Test;

import java.io.IOException;
import java.net.URISyntaxException;

public class DataDrivenTests {

    private final String BUGS_URL = "http://localhost:8080/bugs";

    @Test
    void testPOSTRequestToCreateBugOne() throws URISyntaxException, IOException {

        String bugBodyJson = FileUtil.readResourceFileAsString("bugs/bug_01.json");

        String bugId = RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(bugBodyJson)
                .when()
                    .post(BUGS_URL)
                .then()
                    .statusCode(201)
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
                    .statusCode(200);
    }
}
