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

    @DataProvider(name = "bugPayloads")
    public Iterator<BugRequestBody> bugPayloads() {
        List<BugRequestBody> bugRequests = new ArrayList<>();
        List<List<String>> records = FileUtil.readCSVFromResources("bugs/bugs.csv");

        // Skip the header row
        for (int i = 1; i < records.size(); i++) {
            List<String> record = records.get(i);
            BugRequestBody bug = BugRequestBody.builder()
                    .createdBy(record.get(0))
                    .priority(Integer.valueOf(record.get(1)))
                    .severity(record.get(2))
                    .title(record.get(3))
                    .completed(Boolean.parseBoolean(record.get(4)))
                    .build();
            bugRequests.add(bug);
        }

        return bugRequests.iterator();
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
