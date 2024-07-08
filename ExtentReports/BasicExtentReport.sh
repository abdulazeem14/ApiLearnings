#################################
Creating a basic Extent Report
#################################

######################

##### Notes:

# Reporters
# Extent allows creation of tests, nodes, events and assignment of tags, devices, authors, environment values etc. This information can be printed to multiple destinations. In our context, a reporter defines the destination.

# The ExtentSparkReporter is a rich-HTML reporter that is part of the standard ExtentReports library. It supports both Behavior-Driven Development (BDD) and non-BDD test styles. This reporting tool allows for the generation of visually appealing and detailed test reports in HTML format. Users can customize the configuration of each reporter using XML, JSON, or Java to fit their specific reporting needs. The ExtentSparkReporter is designed to provide a comprehensive overview of test execution, including test cases, tags, bugs, and a dashboard view for a quick summary of test results

######################



=> Add the following code to the BugsApiTests

# In the below code, we are creating a basic extent report for the tests.
# We are creating a file with the timestamp and adding the tests to the report.


# => First add the imports


package org.loonycorn.restassuredtests;

import com.aventstack.extentreports.ExtentReports;
import com.aventstack.extentreports.ExtentTest;
import com.aventstack.extentreports.Status;
import com.aventstack.extentreports.reporter.ExtentSparkReporter;
import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.http.ContentType;
import io.restassured.specification.ResponseSpecification;
import org.loonycorn.restassuredtests.model.BugRequestBody;

import org.testng.annotations.AfterSuite;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;

import static org.hamcrest.Matchers.*;


# => Then make the changes to the code
# IMPORTANT: DO NOT copy paste everything (the whole code is not here)
# Just copy paste the static ExtentReports first, then copy paste 
# one method at a time
# Please note that for the test methods just copy the two lines that change


public class BugsApiTests {

    private static ExtentReports extent;

    @BeforeSuite
    void setup() {
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

        RestAssured.baseURI = "http://localhost:8090";
        RestAssured.basePath = "bugs";

        RestAssured.requestSpecification = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .build();
    }

    @AfterSuite
    void tearDown() {
        extent.flush();
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
        ExtentTest test = extent.createTest("testPOSTCreateBugOne", "Test to create bug one");

        # The rest of the test code as before

        test.log(Status.INFO, "POST request executed successfully");
    }


    @Test
    public void testPOSTCreateBugTwo() {
        ExtentTest test = extent.createTest("testPOSTCreateBugTwo", "Test to create bug two");

        # The rest of the test code as before


        test.log(Status.INFO, "POST request executed successfully");
    }

    ## No change to the other tests

}

=> Run the test
(All the tests will pass)

=> Go to the reports folder and open the report file
(Right click on the file and select "Open in Browser" -> "Chrome")




# (Observe here we just have 2 tests in the report, but we have around 6 tests in our class

# This is because we are creating a new test for each step and we have done this only for the first 2 tests. We will fix this in the next section.)

# Also observe we have one log info

=> Click on both the links from the left side of the report

=> Click on "#test-id=2" for the second test (note that the URL changes)
# This is an anchor tag that allows us to go directly to a test

=> Copy paste the new URL (with the anchor tag)

=> Open a new tab and paste the URL, notice that we go directly to test 2

=> Click on the charts icon on the left

=> Hover over the two sections of the line chart (timeline for tests)




#################################

=> Add the ExtentTest logging to each test (only add the test instance and logging)
# The rest of the code in each test remains the same

# In the below code, we are creating a basic extent report for the tests.
# We are creating a file with the timestamp and adding the tests to the report.
# Observe we have 6 steps in the report and we have added 6 tests to the report.

# This is quite repetitive and we can use TestNG listeners to automate this process.
# This we will be doing in the next demo



public class BugsApiTests {

    # No change to this code


    @Test(dependsOnMethods = {"testPOSTCreateBugOne", "testPOSTCreateBugTwo"})
    public void testGETRetrieveBugs() {
        ExtentTest test = extent.createTest("testGETRetrieveBugs", "Test to retrieve bugs");

        ...

        test.log(Status.INFO, "The GET request to retrieve bugs has been executed successfully.");
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    public void testPUTUpdateBugOne() {
        ExtentTest test = extent.createTest("testPUTUpdateBugOne", "Test to update bug one");

        ...

        test.log(Status.INFO, "The PUT request to update bug one has been executed successfully.");
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    public void testPATCHUpdateBugTwo() {
        ExtentTest test = extent.createTest("testPATCHUpdateBugTwo", "Test to patch update bug two");

        ...

        test.log(Status.INFO, "The PATCH request to update bug two has been executed successfully.");
    }

    @Test(dependsOnMethods = "testPATCHUpdateBugTwo")
    public void testDELETEAllBugs() {
        ExtentTest test = extent.createTest("testDELETEAllBugs", "Test to delete all bugs");

        ...

        test.log(Status.INFO, "The DELETE request to delete all bugs has been executed successfully.");
    }

}

=> Run the test
(All the tests will pass)

=> Go to the reports folder and open the recent report file
(Right click on the file and select "Open in Browser" -> "Chrome")

# (Observe that we have 6 tests and each test has its own steps)

=> Click on both the links from the left side of the report


#################################

=> Get one test to fail

=> In testGETRetrieveBugs change the expectation of size to 3


.body("size()", equalTo(3))


=> Run all the tests, 2 will pass, 1 fails, 3 skips

=> Go to the extent report and the report is misleading

=> Shows 3 tests as passed. The skipped tests are not present

=> Click on the testGETRetrieveBugs report - show that there is no log there but still the test is marked as passed

# We will fix this in the next part

=> IMPORTANT: Make sure you go back and fix the test so it passes

=> Also restart the Bugs API server so we start afresh
























