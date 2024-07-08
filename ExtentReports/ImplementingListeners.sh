#################################
Automating Test Logging with TestNG Listeners
#################################
# https://medium.com/@kukidas.09/extent-report-as-reporting-framework-for-api-automation-f75c472e3d49
# https://www.youtube.com/watch?v=Lapn6VLoqdc
# https://www.youtube.com/watch?v=ZcokOPV3-Yk&list=PL-a9eJ2NZlbRFnZbN8glYFGaEudds86-k&index=14


#################################


=> IMPORTANT: Delete all the previous reports that were generated (leave the reports/ folder)

=> Create a new package called "listeners" under the "test > java > org.loonycorn.restassuredtests" package

=> Under "listeners" package, create a new class called "ExtentManager.java"
=> Under "listeners" package, create a new class called "ExtentTestNGListener.java"

#################################
# ExtentManager.java
# Please note that we use the synchronized keyword to allow this to be accessed on multiple threads
# It is possible to run TestNG tests on multiple threads (though we don't do that here)

package org.loonycorn.restassuredtests.listeners;

import com.aventstack.extentreports.ExtentReports;
import com.aventstack.extentreports.reporter.ExtentSparkReporter;

import java.io.File;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ExtentManager {
    private static ExtentReports extent;

     public synchronized static ExtentReports getExtentReports() {
        if (extent == null) {
            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd_HHmmss");
            String timestamp = formatter.format(new Date());
            String filename = "bugs-report-" + timestamp + ".html";

            File reportsDir = new File(Paths.get(System.getProperty("user.dir"), "reports").toString());
            if (!reportsDir.exists()) {
                reportsDir.mkdirs();
            }

            String filePath = Paths.get(reportsDir.getAbsolutePath(), filename).toString();

            ExtentSparkReporter sparkReporter = new ExtentSparkReporter(filePath);
            extent = new ExtentReports();
            extent.attachReporter(sparkReporter);
        }

        return extent;
    }

    public synchronized static void flushExtentReports() {
         if (extent != null) {
             extent.flush();
         }
    }
}


#################################
# ExtentTestNGListener.java


package org.loonycorn.restassuredtests.listeners;

import com.aventstack.extentreports.ExtentReports;
import com.aventstack.extentreports.ExtentTest;
import com.aventstack.extentreports.Status;

import org.testng.ITestContext;
import org.testng.ITestListener;
import org.testng.ITestResult;

public class ExtentTestNGListener implements ITestListener {
    private static ExtentReports extent;

    @Override
    public void onStart(ITestContext context) {
        extent = ExtentManager.getExtentReports();
    }

    @Override
    public void onTestStart(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = extent.createTest(
                methodName, result.getMethod().getDescription());

        result.setAttribute(methodName + "-extentTest", extentTest);
    }

    @Override
    public void onTestSuccess(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");

        String log = "The test " + methodName + " was successful.";

        extentTest.log(Status.INFO, log);
    }

    @Override
    public void onFinish(ITestContext context) {
        ExtentManager.flushExtentReports();
    }
}


=> Click on "Command" + Click on "ITestListener" interface to look at all the methods




#################################
# BugsApiTests.java

# Please note that I have removed all reference to reporting from the test cases


package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.http.ContentType;
import io.restassured.specification.ResponseSpecification;
import org.loonycorn.restassuredtests.model.BugRequestBody;

import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import java.util.List;

import static org.hamcrest.Matchers.*;

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

    @Test
    public void testPOSTCreateBugOne() {
        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 3, "High",
                "Cannot filter by category", false
        );

        ResponseSpecification responseSpec = createResponseSpec(bug);

        RestAssured
                .given()
                    .body(bug)
                .when()
                    .post()
                .then()
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

        RestAssured
                .given()
                    .body(bug)
                .when()
                    .post()
                .then()
                    .statusCode(201)
                    .spec(responseSpec);
    }


    @Test(dependsOnMethods = {"testPOSTCreateBugOne", "testPOSTCreateBugTwo"})
    public void testGETRetrieveBugs() {
        RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .body("size()", equalTo(2));
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

        RestAssured
                .given()
                    .pathParam("bug_id", bugId)
                    .body(bug)
                .when()
                    .put("/{bug_id}")
                .then()
                    .statusCode(200)
                    .spec(responseSpec);
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

        RestAssured
                .given()
                    .pathParam("bug_id", bugId)
                    .body(bug)
                .when()
                    .patch("/{bug_id}")
                .then()
                    .statusCode(200)
                    .body("completed", equalTo(bug.getCompleted()));
    }

    @Test(dependsOnMethods = "testPATCHUpdateBugTwo")
    public void testDELETEAllBugs() {
        List<String> bugIds = RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .extract().path("bugId");

        for (String bugId : bugIds) {
            RestAssured
                    .given()
                        .pathParam("bug_id", bugId)
                    .when()
                        .delete("/{bug_id}")
                    .then()
                        .statusCode(200)
                        .body("bug_id", equalTo(bugId));
        }

        RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .body("size()", equalTo(0));
    }

}

#################################

=> Run the BugsApiTests.java file
(Observe no report has been generated, but all tests passes)
# This is because we have not yet implemented the listener in the BugsApiTests.java file



=> Add this one anotation to BugsApiTests class on the BugsApiTests.java file

# BugsApiTests.java

# Same code as before

@Listeners(ExtentTestNGListener.class)
public class BugsApiTests {

}

# You will need to import the classes


=> Run the BugsApiTests.java file
(All the tests should pass and the report should be generated in the "reports" folder)

=> Open and show the report


#################################

# Now lets try failing a test and see how the report looks like

=> Open the BugsApiTests.java file and replace just one of the tests with the following code

# Are checking if the number of bugs are 1, but there are 2 bugs, so this test should fail

# Only need to change the equalTo()


public void testGETRetrieveBugs() {
    RestAssured
            .get()
            .then()
            .statusCode(200)
            .body("size()", equalTo(1));
}

=> Run the BugsApiTests.java file
(Observe that the test fails and the remaining tests are skipped
    the report is generated in the "reports" folder)

=> Open and show the report
(Observe the first 2 tests passes and logs are generated as expected, also observe all the other tests
are morked as pass and there are no logs for them)

# We still haven't fixed this problem


#################################

=> Open "ExtentTestNGListener.java" file and replace with the following code
# Have replaced info with pass in the on success method, have implemented fail and skip methods

# ExtentTestNGListener.java

# Replace the onTestSuccess and add two more methods


    @Override
    public void onTestSuccess(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");

        String log = "The test " + methodName + " was successful.";

        extentTest.log(Status.PASS, log);
    }

    @Override
    public void onTestFailure(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");

        String log = "The test " + methodName + " failed: " + result.getThrowable().getMessage();

        extentTest.log(Status.FAIL, log);
    }

    @Override
    public void onTestSkipped(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");

        String log = "The test " + methodName + " was skipped.";

        extentTest.log(Status.SKIP, log);
    }



#################################

=> Run the BugsApiTests.java file
(Observe that the test fails and the report is generated in the "reports" folder)

=> Open and show the report
(Observe now we can see properly which test passed, failed and skipped with proper logs)


=> Click on each test

=> Click on the Chart on the left which shows how many tests failed, how many passed, how many skipped
=> Hover over the charts and show


#################################

# Let's add more details to the logs

# Add these two helper methods to BugsApiTests.java (just below createResponseSpec near the top of the class)


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


# Update just one test to have these details


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


# Go to the ExtentTestNGListener class

# Add this method to the very bottom


    private void logRequestAndResponseDetails(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");
        QueryableRequestSpecification requestSpec = (QueryableRequestSpecification) result.getAttribute(
                methodName + "-requestSpec");

        if (requestSpec != null) {
            extentTest.log(Status.INFO, "Endpoint is: " + requestSpec.getURI());
            extentTest.log(Status.INFO, "Request body is: " + requestSpec.getBody());
        }

        Response response = (Response) result.getAttribute(methodName + "-response");

        if (response != null) {
            extentTest.log(Status.INFO, "Status is: " + response.getStatusCode());

            String[][] arrayHeaders = response.getHeaders().asList().stream().map(
                header -> new String[] {header.getName(), header.getValue()}).toArray(String[][] :: new);

            extentTest.log(Status.INFO, "Response headers are: " + Arrays.deepToString(arrayHeaders));
            extentTest.log(Status.INFO, "Response body is: " + response.getBody().prettyPrint());
        }
    }


# Update code for onTestSuccess and onTestFailure

   @Override
    public void onTestSuccess(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");

        String log = "The test " + methodName + " was successful.";

        extentTest.log(Status.PASS, log);

        logRequestAndResponseDetails(result);
    }

    @Override
    public void onTestFailure(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");

        String log = "The test " + methodName + " failed: " + result.getThrowable().getMessage();

        extentTest.log(Status.FAIL, log);

        logRequestAndResponseDetails(result);
    }    


# Code should look like this:

package org.loonycorn.restassuredtests.listeners;

import com.aventstack.extentreports.ExtentReports;
import com.aventstack.extentreports.ExtentTest;
import com.aventstack.extentreports.Status;

import io.restassured.response.Response;
import io.restassured.specification.QueryableRequestSpecification;
import org.testng.ITestContext;
import org.testng.ITestListener;
import org.testng.ITestResult;

import java.util.Arrays;

public class ExtentTestNGListener implements ITestListener {
    private static ExtentReports extent;

    @Override
    public void onStart(ITestContext context) {
        extent = ExtentManager.getExtentReports();
    }

    @Override
    public void onTestStart(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = extent.createTest(
                methodName, result.getMethod().getDescription());

        result.setAttribute(methodName + "-extentTest", extentTest);
    }

    @Override
    public void onTestSuccess(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");

        String log = "The test " + methodName + " was successful.";

        extentTest.log(Status.PASS, log);

        logRequestAndResponseDetails(result);
    }

    @Override
    public void onTestFailure(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");

        String log = "The test " + methodName + " failed: " + result.getThrowable().getMessage();

        extentTest.log(Status.FAIL, log);

        logRequestAndResponseDetails(result);
    }

    @Override
    public void onTestSkipped(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");

        String log = "The test " + methodName + " was skipped.";

        extentTest.log(Status.SKIP, log);
    }

    @Override
    public void onFinish(ITestContext context) {
        ExtentManager.flushExtentReports();
    }

    private void logRequestAndResponseDetails(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");
        QueryableRequestSpecification requestSpec = (QueryableRequestSpecification) result.getAttribute(
                methodName + "-requestSpec");

        if (requestSpec != null) {
            extentTest.log(Status.INFO, "Endpoint is: " + requestSpec.getURI());
            extentTest.log(Status.INFO, "Request body is: " + requestSpec.getBody());
        }

        Response response = (Response) result.getAttribute(methodName + "-response");

        if (response != null) {
            extentTest.log(Status.INFO, "Status is: " + response.getStatusCode());

            String[][] arrayHeaders = response.getHeaders().asList().stream().map(
                header -> new String[] {header.getName(), header.getValue()}).toArray(String[][] :: new);

            extentTest.log(Status.INFO, "Response headers are: " + Arrays.deepToString(arrayHeaders));
            extentTest.log(Status.INFO, "Response body is: " + response.getBody().prettyPrint());
        }
    }
}


# Run the entire test suite

# Show the bug-report - only one test has the details


#################################

# Let's update the remaining tests as well

# BugsAPITests.java

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

    @Test(dependsOnMethods = "testPATCHUpdateBugTwo")
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


######################################

# Run the tests, the testGETRetrieveBugs should fail and the rest skipped (failed because our API server has many bugs)

# Go to the bug-report and show the details

# Click on all the individual tests and show

# Restart the API server

# Re-run the tests

# Everything should pass

# Show the bug report - click on all the individual tests and show






























