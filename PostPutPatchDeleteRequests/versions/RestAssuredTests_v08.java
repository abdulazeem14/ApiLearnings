package org.loonycorn.restassuredtests;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String BUGS_URL = "http://localhost:8090/bugs";

    @Test
    public void testPOSTCreateBugOne() throws JsonProcessingException {

        ObjectMapper objectMapper = new ObjectMapper();
        ObjectNode bug = objectMapper.createObjectNode();

        bug.put("createdBy", "Joseph Wang");
        bug.put("priority", 3);
        bug.put("severity", "High");
        bug.put("title", "Cannot filter by category");
        bug.put("completed", false);

        String bugBodyJson = objectMapper.writeValueAsString(bug);

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

    @Test
    public void testPOSTCreateBugTwo() throws JsonProcessingException {

        ObjectMapper objectMapper = new ObjectMapper();
        ObjectNode bug = objectMapper.createObjectNode();

        bug.put("createdBy", "Norah Jones");
        bug.put("priority", 0);
        bug.put("severity", "Critical");
        bug.put("title", "Home page does not load");
        bug.put("completed", false);

        String bugBodyJson = objectMapper.writeValueAsString(bug);

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

    @Test(dependsOnMethods = { "testPOSTCreateBugOne", "testPOSTCreateBugTwo" })
    public void testGETTwoBugsPresent() {

        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                .when()
                    .get(BUGS_URL)
                .then()
                .statusCode(200)
                .body("size()", equalTo(2));
    }

    @Test(dependsOnMethods = { "testGETTwoBugsPresent" })
    public void testPUTUpdateBugOne() throws JsonProcessingException {

        String bugIdOne = RestAssured
                .given()
                    .contentType(ContentType.JSON)
                .when()
                    .get(BUGS_URL)
                .then()
                    .statusCode(200)
                    .extract().path("bugId[0]");

        ObjectMapper objectMapper = new ObjectMapper();
        ObjectNode bug = objectMapper.createObjectNode();

        // Changed priority, severity, and completed
        bug.put("createdBy", "Joseph Wang");
        bug.put("priority", 2);
        bug.put("severity", "Low");
        bug.put("title", "Cannot filter by category");
        bug.put("completed", true);

        String bugBodyJson = objectMapper.writeValueAsString(bug);

        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .baseUri(BUGS_URL)
                    .body(bugBodyJson)
                    .pathParam("bug_id", bugIdOne)
                .when()
                    .put("/{bug_id}")
                .then()
                    .statusCode(200)
                    .body("createdBy", equalTo(bug.get("createdBy").asText()),
                            "priority", equalTo(bug.get("priority").asInt()),
                            "severity", equalTo(bug.get("severity").asText()),
                            "title", equalTo(bug.get("title").asText()),
                            "completed", equalTo(bug.get("completed").asBoolean())
                    );
    }

    @Test(dependsOnMethods = { "testPUTUpdateBugOne" })
    public void testPATCHUpdateBugTwo() throws JsonProcessingException {

        String bugIdTwo = RestAssured
                .given()
                    .contentType(ContentType.JSON)
                .when()
                    .get(BUGS_URL)
                .then()
                    .statusCode(200)
                    .extract().path("bugId[1]");

        ObjectMapper objectMapper = new ObjectMapper();
        ObjectNode bug = objectMapper.createObjectNode();

        // Changed title
        bug.put("title", "HOME PAGE DOES NOT LOAD");

        String bugBodyJson = objectMapper.writeValueAsString(bug);

        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .baseUri(BUGS_URL)
                    .body(bugBodyJson)
                    .pathParam("bug_id", bugIdTwo)
                .when()
                    .patch("/{bug_id}")
                .then()
                    .statusCode(200)
                    .body("createdBy", equalTo("Norah Jones"),
                            "priority", equalTo(0),
                            "severity", equalTo("Critical"),
                            "title", equalTo(bug.get("title").asText()),
                            "completed", equalTo(false)
                    );
    }

    @Test(dependsOnMethods = { "testPATCHUpdateBugTwo" })
    public void testDELETERemoveBugOne() {

        String bugIdOne = RestAssured
                .given()
                    .contentType(ContentType.JSON)
                .when()
                    .get(BUGS_URL)
                .then()
                    .statusCode(200)
                    .extract().path("bugId[0]");

        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .baseUri(BUGS_URL)
                    .pathParam("bug_id", bugIdOne)
                .when()
                    .delete("/{bug_id}")
                .then()
                    .statusCode(200)
                    .body("bug_id", equalTo(bugIdOne));
    }

}