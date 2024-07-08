package org.loonycorn.restassuredtests;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String BUGS_URL = "http://localhost:8090/bugs";

    @Test
    public void testPOSTCreateBug() {
        String bugBodyJson = null;

        ObjectMapper objectMapper = new ObjectMapper();
        ObjectNode bug = objectMapper.createObjectNode();

        bug.put("createdBy", "Joseph Wang");
        bug.put("priority", 3);
        bug.put("severity", "High");
        bug.put("title", "Cannot filter by category");
        bug.put("completed", false);

        try {
            bugBodyJson = objectMapper.writeValueAsString(bug);
        } catch (Exception e) {
            e.printStackTrace();
        }

        String bugId = RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(bugBodyJson)
                .when()
                    .post(BUGS_URL)
                .then()
                    .statusCode(201)
                    .body("createdBy", equalTo(bug.get("createdBy").asText()),
                            "priority", equalTo(bug.get("priority").asInt()),
                            "severity", equalTo(bug.get("severity").asText()),
                            "title", equalTo(bug.get("title").asText()),
                            "completed", equalTo(bug.get("completed").asBoolean())
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
                    .body("createdBy", equalTo(bug.get("createdBy").asText()))
                    .body("priority", equalTo(bug.get("priority").asInt()))
                    .body("severity", equalTo(bug.get("severity").asText()))
                    .body("title", equalToIgnoringCase(bug.get("title").asText()))
                    .body("completed", equalTo(bug.get("completed").asBoolean()));

    }

}