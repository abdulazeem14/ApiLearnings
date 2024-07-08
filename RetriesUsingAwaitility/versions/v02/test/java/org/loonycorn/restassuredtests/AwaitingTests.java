package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.http.ContentType;
import io.restassured.specification.ResponseSpecification;
import org.loonycorn.restassuredtests.model.BugRequestBody;

import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;
import java.util.concurrent.TimeUnit;

import java.util.List;
import java.util.concurrent.atomic.AtomicReference;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class AwaitingTests {

    private static final int MAX_ATTEMPTS = 10;
    private static final long INTERVAL_SECONDS = 1;

    @BeforeSuite
    void setup() {
        RestAssured.baseURI = "http://localhost:8080";
        RestAssured.basePath = "bugs";

        RestAssured.requestSpecification = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .build();
    }

    private ResponseSpecification createResponseSpec(BugRequestBody bug) {
        return new ResponseSpecBuilder()
                .expectBody("createdBy", equalTo(bug.getCreatedBy()))
                .expectBody("priority", equalTo(bug.getPriority()))
                .expectBody("severity", equalTo(bug.getSeverity()))
                .expectBody("title", equalToIgnoringCase(bug.getTitle()))
                .expectBody("completed", equalTo(bug.getCompleted()))
                .build();
    }


    private void executeWithRetry(Runnable action) {
        boolean success = false;
        int attempt = 0;

        while (!success && attempt < MAX_ATTEMPTS) {
            try {
                action.run();
                success = true;
            } catch (AssertionError e) {
                System.out.println(String.format(
                        "Request failed (%d/%d), retrying in %d seconds...",
                        attempt + 1, MAX_ATTEMPTS, INTERVAL_SECONDS)
                );

                attempt++;
                try {
                    TimeUnit.SECONDS.sleep(INTERVAL_SECONDS);
                } catch (InterruptedException interrupted) {
                }
            }
        }
        if (!success) {
            throw new AssertionError(
                    "Action failed after " + MAX_ATTEMPTS + " attempts.");
        }
    }

    @Test
    public void testPOSTCreateBug() {
        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 3, "High",
                "Cannot filter by category", false
        );

        ResponseSpecification responseSpec = createResponseSpec(bug);

        executeWithRetry(() -> {
            RestAssured
                    .given()
                        .body(bug)
                    .when()
                        .post()
                    .then()
                        .statusCode(201)
                        .spec(responseSpec);
        });
    }

    @Test(dependsOnMethods = "testPOSTCreateBug")
    public void testGETRetrieveBugs() {
        executeWithRetry(() -> {
            RestAssured
                    .get()
                    .then()
                        .statusCode(200)
                        .body("size()", greaterThan(0));
        });
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    public void testPUTUpdateBug() {
        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 1, "Critical",
                "Homepage hangs", false
        );

        ResponseSpecification responseSpec = createResponseSpec(bug);

        AtomicReference<String> bugId = new AtomicReference<>();

        executeWithRetry(() -> {
            bugId.set(RestAssured
                        .get()
                        .then()
                            .statusCode(200)
                            .extract().path("bugId[0]"));
        });

        assertThat(bugId, notNullValue());

        executeWithRetry(() -> {
            RestAssured
                    .given()
                        .pathParam("bug_id", bugId.get())
                        .body(bug)
                    .when()
                        .put("/{bug_id}")
                    .then()
                        .statusCode(200)
                        .spec(responseSpec);
        });
    }

    @Test(dependsOnMethods = "testPUTUpdateBug")
    public void testDELETEAllBugs() {

        AtomicReference<List<String>> bugIds = new AtomicReference<>();

        executeWithRetry(() -> {
            bugIds.set(RestAssured
                    .get()
                    .then()
                        .statusCode(200)
                        .extract().path("bugId")
            );
        });

        for (String bugId : bugIds.get()) {
            executeWithRetry(() -> {
                RestAssured
                        .given()
                            .pathParam("bug_id", bugId)
                        .when()
                            .delete("/{bug_id}")
                        .then()
                            .statusCode(200)
                            .body("bug_id", equalTo(bugId));
            });
        }
    }

}