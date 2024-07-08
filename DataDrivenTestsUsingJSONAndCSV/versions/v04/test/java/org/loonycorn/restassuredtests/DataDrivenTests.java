package org.loonycorn.restassuredtests;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.restassured.RestAssured;
import org.loonycorn.restassuredtests.model.BugRequestBody;
import org.testng.annotations.DataProvider;
import io.restassured.http.ContentType;
import org.loonycorn.restassuredtests.utils.FileUtil;
import org.testng.annotations.Test;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import static org.hamcrest.Matchers.*;

public class DataDrivenTests {

    private final String BUGS_URL = "http://localhost:8080/bugs";
    private static final ObjectMapper objectMapper = new ObjectMapper();

    @DataProvider(name = "bugPayloads")
    public Iterator<BugRequestBody> bugPayloads() throws URISyntaxException, IOException {
        JsonNode jsonArray = FileUtil.readJsonFileAsJsonNode("bugs/all_bugs.json");

        List<BugRequestBody> bugList = new ArrayList<>();
        for (JsonNode element : jsonArray) {
            BugRequestBody bug = objectMapper.treeToValue(element, BugRequestBody.class);
            bugList.add(bug);
        }

        return bugList.iterator();
    }

    @Test(dataProvider = "bugPayloads")
    void testPOSTRequestToCreateBug(BugRequestBody bug) {

        String bugId = RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(bug)
                .when()
                    .post(BUGS_URL)
                .then()
                    .statusCode(201)
                    .body("bugId", notNullValue())
                    .body("createdOn", notNullValue())
                    .body("updatedOn", notNullValue())
                    .body("createdBy", equalTo(bug.getCreatedBy()))
                    .body("priority", equalTo(bug.getPriority()))
                    .body("severity", equalTo(bug.getSeverity()))
                    .body("title", equalTo(bug.getTitle()))
                    .body("completed", equalTo(bug.getCompleted()))
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
                    .body("createdOn", notNullValue())
                    .body("updatedOn", notNullValue())
                    .body("createdBy", equalTo(bug.getCreatedBy()))
                    .body("priority", equalTo(bug.getPriority()))
                    .body("severity", equalTo(bug.getSeverity()))
                    .body("title", equalTo(bug.getTitle()))
                    .body("completed", equalTo(bug.getCompleted()));
    }
}
