package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.DataProvider;
import io.restassured.http.ContentType;
import org.loonycorn.restassuredtests.utils.FileUtil;
import org.testng.annotations.Test;

import java.io.IOException;
import java.net.URISyntaxException;

public class DataDrivenTests {

    private final String BUGS_URL = "http://localhost:8080/bugs";

    @DataProvider(name = "bugPayloads")
    public Object[][] bugPayloads() throws URISyntaxException, IOException {
        return new Object[][] {
                {FileUtil.readResourceFileAsString("bugs/bug_01.json")},
                {FileUtil.readResourceFileAsString("bugs/bug_02.json")},
                {FileUtil.readResourceFileAsString("bugs/bug_03.json")}
        };
    }

    @Test(dataProvider = "bugPayloads")
    void testPOSTRequestToCreateBug(String bugBodyJson) {

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
