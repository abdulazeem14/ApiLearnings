package org.loonycorn.restassuredtests;

import com.fasterxml.jackson.databind.JsonNode;
import io.restassured.RestAssured;
import org.testng.annotations.DataProvider;
import io.restassured.http.ContentType;
import org.loonycorn.restassuredtests.utils.FileUtil;
import org.testng.annotations.Test;

import java.io.IOException;
import java.net.URISyntaxException;

import static org.hamcrest.Matchers.*;

public class DataDrivenTests {

    private final String BUGS_URL = "http://localhost:8080/bugs";

    @DataProvider(name = "bugPayloads")
    public Object[][] bugPayloads() throws URISyntaxException, IOException {
        return new Object[][] {
                {FileUtil.readJsonFileAsJsonNode("bugs/bug_01.json")},
                {FileUtil.readJsonFileAsJsonNode("bugs/bug_02.json")},
                {FileUtil.readJsonFileAsJsonNode("bugs/bug_03.json")}
        };
    }

    @Test(dataProvider = "bugPayloads")
    void testPOSTRequestToCreateBug(JsonNode bugBodyJson) {

        String bugId = RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(bugBodyJson.toString())
                .when()
                    .post(BUGS_URL)
                .then()
                    .statusCode(201)
                    .body("bugId", notNullValue())
                    .body("createdBy", equalTo(bugBodyJson.get("createdBy").asText()))
                    .body("priority", equalTo(bugBodyJson.get("priority").asInt()))
                    .body("severity", equalTo(bugBodyJson.get("severity").asText()))
                    .body("title", equalToIgnoringCase(bugBodyJson.get("title").asText()))
                    .body("completed", equalTo(bugBodyJson.get("completed").asBoolean()))
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
                    .body("bugId", equalTo(bugId))
                    .body("createdBy", equalTo(bugBodyJson.get("createdBy").asText()))
                    .body("priority", equalTo(bugBodyJson.get("priority").asInt()))
                    .body("severity", equalTo(bugBodyJson.get("severity").asText()))
                    .body("title", equalToIgnoringCase(bugBodyJson.get("title").asText()))
                    .body("completed", equalTo(bugBodyJson.get("completed").asBoolean()));
    }
}
