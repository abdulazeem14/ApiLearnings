package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import io.restassured.specification.QueryableRequestSpecification;
import io.restassured.specification.RequestSpecification;
import io.restassured.specification.ResponseSpecification;
import io.restassured.specification.SpecificationQuerier;
import org.loonycorn.restassuredtests.listeners.ExtentTestNGListener;
import org.loonycorn.restassuredtests.model.BugRequestBody;

import org.testng.ITestResult;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Listeners;
import org.testng.annotations.Test;
import org.testng.Reporter;

import java.util.List;

import static org.hamcrest.Matchers.*;

@Listeners(ExtentTestNGListener.class)
public class BugsApiTests {

    @BeforeSuite
    void setup() {
        RestAssured.baseURI = "http://localhost:8090";
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


    private void specifyRequestLogDetails(RequestSpecification requestSpec) {
        QueryableRequestSpecification queryableRequestSpecification =
                SpecificationQuerier.query(requestSpec);

        ITestResult result = Reporter.getCurrentTestResult();
        String methodName = result.getMethod().getMethodName();

        result.setAttribute(methodName + "-requestSpec", queryableRequestSpecification);
    }

    private void specifyResponseLogDetails(Response response) {
        ITestResult result = Reporter.getCurrentTestResult();
        String methodName = result.getMethod().getMethodName();

        result.setAttribute(methodName + "-response", response);
    }

    @Test
    public void testPOSTCreateBugOne() {
        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 3, "High",
                "Cannot filter by category", false
        );

        ResponseSpecification responseSpec = createResponseSpec(bug);

        RequestSpecification requestSpec = RestAssured.given().body(bug);

        specifyRequestLogDetails(requestSpec);

        Response response = requestSpec.when().post();

        specifyResponseLogDetails(response);

        response.then()
                .statusCode(201)
                .spec(responseSpec);
    }


    @Test
    public void testPOSTCreateBugTwo() {
        BugRequestBody bug = new BugRequestBody(
                "Norah Jones", 0, "Critical",
                "Home page does not load", false
        );

        ResponseSpecification responseSpec = createResponseSpec(bug);

        RequestSpecification requestSpec = RestAssured.given().body(bug);

        specifyRequestLogDetails(requestSpec);

        Response response = requestSpec.when().post();

        response.then()
                .statusCode(201)
                .spec(responseSpec);

        specifyResponseLogDetails(response);
    }


    @Test(dependsOnMethods = {"testPOSTCreateBugOne", "testPOSTCreateBugTwo"})
    public void testGETRetrieveBugs() {
        RequestSpecification requestSpec = RestAssured.given();

        specifyRequestLogDetails(requestSpec);

        Response response = requestSpec.when().get();

        response.then()
                .statusCode(200)
                .body("size()", equalTo(2));

        specifyResponseLogDetails(response);
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    public void testPUTUpdateBugOne() {
        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 1, "Critical",
                "Homepage hangs", false
        );

        ResponseSpecification responseSpec = createResponseSpec(bug);

        String bugId = RestAssured
                .get()
                .then()
                .statusCode(200)
                .extract().path("bugId[0]");

        RequestSpecification requestSpec = RestAssured.given().pathParam("bug_id", bugId).body(bug);

        specifyRequestLogDetails(requestSpec);

        Response response = requestSpec.when().put("/{bug_id}");

        response.then()
                .statusCode(200)
                .spec(responseSpec);

        specifyResponseLogDetails(response);
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    public void testPATCHUpdateBugTwo() {
        BugRequestBody bug = new BugRequestBody(
                null, null, null,
                null, true
        );

        String bugId = RestAssured
                .get()
                .then()
                .statusCode(200)
                .extract().path("bugId[1]");

        RequestSpecification requestSpec = RestAssured.given().pathParam("bug_id", bugId).body(bug);

        specifyRequestLogDetails(requestSpec);

        Response response = requestSpec.when().patch("/{bug_id}");

        response.then()
                .statusCode(200)
                .body("completed", equalTo(bug.getCompleted()));

        specifyResponseLogDetails(response);
    }

    @Test(dependsOnMethods = {"testPUTUpdateBugOne", "testPATCHUpdateBugTwo"})
    public void testDELETEAllBugs() {
        List<String> bugIds = RestAssured
                .get()
                .then()
                .statusCode(200)
                .extract().path("bugId");

        for (String bugId : bugIds) {
            RequestSpecification requestSpec = RestAssured.given().pathParam("bug_id", bugId);

            specifyRequestLogDetails(requestSpec);

            Response response = requestSpec.when().delete("/{bug_id}");

            response.then()
                    .statusCode(200)
                    .body("bug_id", equalTo(bugId));

            specifyResponseLogDetails(response);
        }

        RequestSpecification requestSpec = RestAssured.given();

        specifyRequestLogDetails(requestSpec);

        Response response = requestSpec.when().get();

        response.then()
                .statusCode(200)
                .body("size()", equalTo(0));

        specifyResponseLogDetails(response);
    }

}