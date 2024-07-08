package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.http.ContentType;
import io.restassured.parsing.Parser;
import io.restassured.response.Response;
import io.restassured.response.ValidatableResponse;
import io.restassured.specification.ResponseSpecification;
import org.loonycorn.restassuredtests.model.BugRequestBody;

import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import java.util.concurrent.TimeUnit;

import java.util.List;
import java.util.concurrent.atomic.AtomicReference;

import static org.awaitility.Awaitility.await;
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
                .setAccept(ContentType.JSON)
                .build();
        RestAssured.defaultParser = Parser.JSON;
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

    @Test
    public void testPOSTCreateBug() {
        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 3, "High",
                "Cannot filter by category", false
        );

        ResponseSpecification responseSpec = createResponseSpec(bug);

        await().atMost(20, TimeUnit.SECONDS).pollInterval(1, TimeUnit.SECONDS).until(() -> {
                ValidatableResponse valResponse = RestAssured
                        .given()
                            .body(bug)
                        .when()
                            .post()
                        .then();

                if (valResponse.extract().response().statusCode() == 201) {
                    valResponse.spec(responseSpec);

                    return true;
                }
                return false;
            }
        );
    }

    @Test(dependsOnMethods = "testPOSTCreateBug")
    public void testGETRetrieveBugs() {
        await().atMost(20, TimeUnit.SECONDS).pollInterval(1, TimeUnit.SECONDS).until(() -> {
                ValidatableResponse valResponse = RestAssured
                        .get()
                        .then();

                if (valResponse.extract().response().statusCode() == 200) {
                    valResponse.body("size()", greaterThan(0));

                    return true;
                }

                return false;
            }
        );
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    public void testPUTUpdateBug() {
        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 1, "Critical",
                "Homepage hangs", false
        );

        ResponseSpecification responseSpec = createResponseSpec(bug);

        AtomicReference<String> bugId = new AtomicReference<>();

        await().atMost(20, TimeUnit.SECONDS).pollInterval(1, TimeUnit.SECONDS).until(() -> {
            bugId.set(RestAssured
                        .get()
                        .then()
                            .statusCode(200)
                            .extract().path("bugId[0]"));
            return true;
        });

        assertThat(bugId, notNullValue());

        await().atMost(20, TimeUnit.SECONDS).pollInterval(1, TimeUnit.SECONDS).until(() -> {
            ValidatableResponse valResponse = RestAssured
                    .given()
                        .pathParam("bug_id", bugId.get())
                        .body(bug)
                    .when()
                        .put("/{bug_id}")
                    .then();

            if (valResponse.extract().response().statusCode() == 200) {
                valResponse.spec(responseSpec);

                return true;
            }

            return false;
        });
    }

    @Test(dependsOnMethods = "testPUTUpdateBug")
    public void testDELETEAllBugs() {

        AtomicReference<List<String>> bugIds = new AtomicReference<>();

        await().atMost(20, TimeUnit.SECONDS).pollInterval(1, TimeUnit.SECONDS).until(() -> {
            Response response = RestAssured
                    .get();

            if (response.statusCode() == 200) {
                bugIds.set(response.path("bugId"));

                return true;
            }

            return false;
        });

        for (String bugId : bugIds.get()) {
            await().atMost(20, TimeUnit.SECONDS).pollInterval(1, TimeUnit.SECONDS).until(() -> {
                ValidatableResponse valResponse = RestAssured
                        .given()
                            .pathParam("bug_id", bugId)
                        .when()
                            .delete("/{bug_id}")
                        .then();

                if (valResponse.extract().response().statusCode() == 200) {
                    valResponse.body("bug_id", equalTo(bugId));

                    return true;
                }

                return false;
            });
        }
    }

}