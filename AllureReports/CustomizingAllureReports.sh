################################
Customizing Allure Reports
################################
# https://medium.com/technology-hits/allure-report-using-maven-and-testng-framework-in-selenium-java-17354c9ff985
# https://medium.com/@sonaldwivedi/allure-reporting-in-selenium-using-testng-and-maven-8a3a5ff07856
# https://www.youtube.com/watch?v=-Udr7E9lHzU&list=PL6SXxvjnlkaRA2S2t9NTWIFrYIjEx3FJt&index=3


################################
# Notes:

# In Allure reporting, the @Epic and @Feature annotations are used to organize and categorize test cases into hierarchical groups, improving the readability and manageability of test reports. These annotations are part of Allure's support for Behavior-Driven Development (BDD) and are used to structure the test report in a way that reflects the features and functionalities of the application being tested. They help to give a clear overview of the test coverage for different parts of the application at a high level.

# @Epic: This annotation is used to mark a class or a test method as part of a larger "epic" or group of features within the application. Epics represent large business goals that can be broken down into smaller features. In the context of testing, labeling tests with the @Epic annotation allows you to group them under these larger goals, providing a high-level overview of which parts of the application the tests are covering and how these parts contribute to the overall business objectives.

# @Feature: This annotation is used to mark a class or a test method as part of a specific feature within the application. Features are typically subsets of epics and represent specific functionalities or aspects of the application. By using the @Feature annotation, you can categorize tests by the application feature they are testing, making it easier to understand the scope of the test coverage for each feature and to identify which features have been thoroughly tested and which may need more attention.

################################

# => Open "BugsApiTest.java" and make the following changes to the code
# BugsApiTest.java


# => Add these imports

import io.qameta.allure.Description;
import io.qameta.allure.Epic;
import io.qameta.allure.Feature;

# => Add the @Epic annotation to the class
# => Add the @Feature and @Description annotations to the test one by one

@Epic("Bugs API Tests")
public class BugsApiTests {

    ...
        
    @Test
    @Feature("Bug Creation")
    @Description("Test to create Bug One")
    public void testPOSTCreateBugOne() {
        ...
    }


    @Test
    @Feature("Bug Creation")
    @Description("Test to create Bug Two")
    public void testPOSTCreateBugTwo() {
        ...
    }


   @Test(dependsOnMethods = {"testPOSTCreateBugOne", "testPOSTCreateBugTwo"})
   @Feature("Bug retrieval")
   @Description("Test to retrieve bugs")
   public void testGETRetrieveBugs() {
        ...
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    @Feature("Bug update")
    @Description("Test to update Bug One")
    public void testPUTUpdateBugOne() {
        ...
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    @Feature("Bug update")
    @Description("Test to update Bug Two")
    public void testPATCHUpdateBugTwo() {
        ...
    }

    @Test(dependsOnMethods = {"testPUTUpdateBugOne", "testPATCHUpdateBugTwo"})
    @Feature("Bug deletion")
    @Description("Test to delete all bugs")
    public void testDELETEAllBugs() {
        ...
    }

}

=> Run the test and observe the "allure-results" folder is created

=> Open the terminal in the IntelliJ and run the below command

$ cd /Users/loonycorn/IdeaProjects/learning-allure-reports

$ allure serve

=> In the report go to "Behaviors"

=> Show how the @Epic and the @Feature have categorized the tests

=> Click on a few individual tests and show how the description has now been updated



################################

# Now lets add steps for each test case, observe here we have added @Step annotation for have one step in
# each test and we have added Allure.step method to add multiple steps in each test case

=> Open "BugsApiTest.java" and change the code as follows

# BugsApiTest.java

# => Replace all the allure imports with this

import io.qameta.allure.*;

# Add @Step and Allure.step()

# => For the 3 methods testPUTUpdateBugOne, testPATCHUpdateBugTwo, testDELETEAllBugs
# => Replace the whole method


@Epic("Bugs API Tests")
public class BugsApiTests {

    ...

    @Test
    @Feature("Bug Creation")
    @Description("Test to create Bug One")
    @Step("Verify first bug successfully created using POST")
    public void testPOSTCreateBugOne() {
        ...
    }


    @Test
    @Feature("Bug Creation")
    @Description("Test to create Bug Two")
    @Step("Verify second bug successfully created using POST")
    public void testPOSTCreateBugTwo() {
        ...
    }


   @Test(dependsOnMethods = {"testPOSTCreateBugOne", "testPOSTCreateBugTwo"})
   @Feature("Bug retrieval")
   @Description("Test to retrieve bugs")
   @Step("Verify bug retrieval returns a list of 2 bugs")
   public void testGETRetrieveBugs() {
        ...
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    @Feature("Bug update")
    @Description("Test to update Bug One")
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

        Allure.step("Retrieve Bug ID for updating");

        RestAssured
                .given()
                    .pathParam("bug_id", bugId)
                    .body(bug)
                .when()
                    .put("/{bug_id}")
                .then()
                    .statusCode(200)
                    .spec(responseSpec);

        Allure.step("Update first bug via PUT request using retrieved Bug ID");
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    @Feature("Bug update")
    @Description("Test to update Bug Two")
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

        Allure.step("Retrieve Bug ID for updating");

        RestAssured
                .given()
                    .pathParam("bug_id", bugId)
                    .body(bug)
                .when()
                    .patch("/{bug_id}")
                .then()
                    .statusCode(200)
                    .body("completed", equalTo(bug.getCompleted()));

        Allure.step("Update first bug via PUT request using retrieved Bug ID");
    }

    @Test(dependsOnMethods = {"testPUTUpdateBugOne", "testPATCHUpdateBugTwo"})
    @Feature("Bug deletion")
    @Description("Test to delete all bugs")
    public void testDELETEAllBugs() {
        List<String> bugIds = RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .extract().path("bugId");

        Allure.step("Retrieving all bug IDs: "+ bugIds);

        for (String bugId : bugIds) {
            RestAssured
                    .given()
                        .pathParam("bug_id", bugId)
                    .when()
                        .delete("/{bug_id}")
                    .then()
                        .statusCode(200)
                        .body("bug_id", equalTo(bugId));

            Allure.step("Deleting bug with ID: "+ bugIds);
        }

        RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .body("size()", equalTo(0));

        Allure.step("Verify all bugs are deleted");
    }

}


=> Run the test and observe the "allure-results" folder is created

=> Open the terminal in the IntelliJ and run the below command

$ allure serve

=> In the report go to "Behaviors"

=> Click on individual tests and show how we can see the steps for each test

=> Some tests have one step and other tests have multiple steps

################################

=> Change a test to cause it to fail

=> In testPATCHUpdateBugTwo change the bug you try to access (index = 2, this bug does not exist)

        String bugId = RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .extract().path("bugId[2]");

=> Run the test and observe the "allure-results" folder is created

=> Open the terminal in the IntelliJ and run the below command

$ allure serve

=> In the report go to "Behaviors"

=> Show the failed bug

=> Notice how only one step was executed for this bug


################################

# Now lets add the severity for each test case
# https://www.youtube.com/watch?v=XIVDs8VNOzE&t=31s

=> Open "BugsApiTest.java" and add the severity

# BugsApiTest.java

@Epic("Bugs API Tests")
public class BugsApiTests {

    ...

    @Test
    @Feature("Bug Creation")
    @Description("Test to create Bug One")
    @Step("Verify first bug successfully created using POST")
    @Severity(SeverityLevel.BLOCKER)
    public void testPOSTCreateBugOne() {
        ...
    }


    @Test
    @Feature("Bug Creation")
    @Description("Test to create Bug Two")
    @Step("Verify second bug successfully created using POST")
    @Severity(SeverityLevel.BLOCKER)
    public void testPOSTCreateBugTwo() {
        ...
    }


    @Test(dependsOnMethods = {"testPOSTCreateBugOne", "testPOSTCreateBugTwo"})
    @Feature("Bug retrieval")
    @Description("Test to retrieve bugs")
    @Step("Verify bug retrieval returns a list of 2 bugs")
    @Severity(SeverityLevel.TRIVIAL)
    public void testGETRetrieveBugs() {
        ...
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    @Feature("Bug update")
    @Description("Test to update Bug One")
    @Severity(SeverityLevel.NORMAL)
    public void testPUTUpdateBugOne() {
        ...
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    @Feature("Bug update")
    @Description("Test to update Bug Two")
    @Severity(SeverityLevel.CRITICAL)
    public void testPATCHUpdateBugTwo() {
        ...
    }

    @Test(dependsOnMethods = {"testPUTUpdateBugOne", "testPATCHUpdateBugTwo"})
    @Feature("Bug deletion")
    @Description("Test to delete all bugs")
    @Severity(SeverityLevel.MINOR)
    public void testDELETEAllBugs() {
        ...
    }

}

=> Run the test and observe the "allure-results" folder is created

=> Open the terminal in the IntelliJ and run the below command

$ allure serve
(Now we can see the severity for each test case in the Allure Report)



################################

# Now lets add the request and response details for each test case

# Added nested steps using lambdas to show intermediate steps

# Every method is a step and we have nested steps under each method

=> Open "BugsApiTest.java" and replace the code with the below code

# BugsApiTest.java

package org.loonycorn.restassuredtests;

import io.qameta.allure.*;

import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import io.restassured.specification.QueryableRequestSpecification;
import io.restassured.specification.RequestSpecification;
import io.restassured.specification.ResponseSpecification;
import io.restassured.specification.SpecificationQuerier;
import org.loonycorn.restassuredtests.model.BugRequestBody;

import org.testng.ITestResult;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;
import org.testng.Reporter;

import java.util.List;

import static org.hamcrest.Matchers.*;

@Epic("Bugs API Tests")
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

    private void logRequestDetails(RequestSpecification requestSpec) {
        ITestResult result = Reporter.getCurrentTestResult();
        String methodName = result.getMethod().getMethodName();

        if (requestSpec != null) {
            QueryableRequestSpecification queryableRequestSpecification = SpecificationQuerier.query(requestSpec);

            Allure.step(methodName + " Request Details", step -> {
                Allure.addAttachment("Endpoint", queryableRequestSpecification.getURI());

                if (queryableRequestSpecification.getBody() != null) {
                    Allure.addAttachment("Request Body", queryableRequestSpecification.getBody().toString());
                }
            });
        }
    }

    private void logResponseDetails(Response response) {
        ITestResult result = Reporter.getCurrentTestResult();
        String methodName = result.getMethod().getMethodName();

        if (response != null) {

            Allure.step(methodName + " Response Details", step -> {
                Allure.addAttachment("Status", String.valueOf(response.getStatusCode()));

                if (response.getBody() != null) {
                    Allure.addAttachment("Response Body", response.getBody().asPrettyString());
                }
            });
        }
    }

    @Test
    @Feature("Bug Creation")
    @Description("Test to create Bug One")
    @Step("Verify first bug successfully created using POST")
    @Severity(SeverityLevel.BLOCKER)
    public void testPOSTCreateBugOne() {
        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 3, "High",
                "Cannot filter by category", false
        );

        ResponseSpecification responseSpec = createResponseSpec(bug);

        RequestSpecification requestSpec = RestAssured.given().body(bug);

        logRequestDetails(requestSpec);

        Response response = requestSpec.when().post();

        logResponseDetails(response);

        response.then()
                .statusCode(201)
                .spec(responseSpec);
    }


    @Test
    @Feature("Bug Creation")
    @Description("Test to create Bug Two")
    @Step("Verify second bug successfully created using POST")
    @Severity(SeverityLevel.BLOCKER)
    public void testPOSTCreateBugTwo() {
        BugRequestBody bug = new BugRequestBody(
                "Norah Jones", 0, "Critical",
                "Home page does not load", false
        );

        ResponseSpecification responseSpec = createResponseSpec(bug);

        RequestSpecification requestSpec = RestAssured.given().body(bug);

        logRequestDetails(requestSpec);

        Response response = requestSpec.when().post();

        response.then()
                .statusCode(201)
                .spec(responseSpec);

        logResponseDetails(response);
    }


   @Test(dependsOnMethods = {"testPOSTCreateBugOne", "testPOSTCreateBugTwo"})
   @Feature("Bug retrieval")
   @Description("Test to retrieve bugs")
   @Step("Verify bug retrieval returns a list of 2 bugs")
   @Severity(SeverityLevel.TRIVIAL)
   public void testGETRetrieveBugs() {
        RequestSpecification requestSpec = RestAssured.given();

        logRequestDetails(requestSpec);

        Response response = requestSpec.when().get();

        response.then()
                .statusCode(200)
                .body("size()", equalTo(2));

        logResponseDetails(response);
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    @Feature("Bug update")
    @Description("Test to update Bug One")
    @Step("Update bug using PUT and verify")
    @Severity(SeverityLevel.NORMAL)
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

        logRequestDetails(requestSpec);

        Response response = requestSpec.when().put("/{bug_id}");

        response.then()
                .statusCode(200)
                .spec(responseSpec);

        logResponseDetails(response);
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    @Feature("Bug update")
    @Description("Test to update Bug Two")
    @Step("Update bug using PATCH and verify")
    @Severity(SeverityLevel.CRITICAL)
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

        logRequestDetails(requestSpec);

        Response response = requestSpec.when().patch("/{bug_id}");

        response.then()
                .statusCode(200)
                .body("completed", equalTo(bug.getCompleted()));

        logResponseDetails(response);
    }

    @Test(dependsOnMethods = {"testPUTUpdateBugOne", "testPATCHUpdateBugTwo"})
    @Feature("Bug deletion")
    @Description("Test to delete all bugs")
    @Step("Delete all bugs and verify")
    @Severity(SeverityLevel.MINOR)
    public void testDELETEAllBugs() {
        List<String> bugIds = RestAssured
                .get()
                .then()
                .statusCode(200)
                .extract().path("bugId");

        for (String bugId : bugIds) {
            RequestSpecification requestSpec = RestAssured.given().pathParam("bug_id", bugId);

            logRequestDetails(requestSpec);

            Response response = requestSpec.when().delete("/{bug_id}");

            response.then()
                    .statusCode(200)
                    .body("bug_id", equalTo(bugId));

            logResponseDetails(response);
        }

        RequestSpecification requestSpec = RestAssured.given();

        logRequestDetails(requestSpec);

        Response response = requestSpec.when().get();

        response.then()
                .statusCode(200)
                .body("size()", equalTo(0));

        logResponseDetails(response);
    }

}


=> Run the test and observe the "allure-results" folder is created

=> Open the terminal in the IntelliJ and run the below command

$ allure serve
# (Now we can see the request and response details for each test case in the Allure Report)

=> go to Suites -> Expand the individual tests

# IMPORTANT: Select a POST request, a PUT request, a PATCH request and show the nested steps with attachments (expand and show)



################################

# Now lets try to fail a test and observe the Allure Report

=> Open "BugsApiTest.java" and replace one code block in testGETRetrieveBugs


        response.then()
                .statusCode(200)
                .body("size()", equalTo(3));



=> Run the test and observe the "allure-results" folder is created

=> Open the terminal in the IntelliJ and run the below command

$ allure serve
(Now we can see the failed test case in the Allure Report,
Click on the error message to see the stack trace of the error message)

=> IMPORTANT: Make sure to change the test back so it passes

        response.then()
                .statusCode(200)
                .body("size()", equalTo(2));


=> Restart the bugs-api application so that we get a clean slate for the next section



################################

# Now lets see how we can measure the speed of the test cases

=> Delete "allure-results" folder
(We are doing this because if we have many reports from before it will be difficult to see the speed of the test cases)

=> Stop the bugs-api server

=> Open "BugController.java" and replace the code with the below code

# Here we are adding a delay from 5 to 15 seconds for POST, PUT and DELETE requests
# BugController.java

# Add an import

import java.util.*;

# Add a new member variable on top

private final Random rand = new Random();


# =>  Add this to the following methods 
# => createBug, 
# => updateBug
# => deleteBug


        try {
            Thread.sleep(rand.nextInt(10000) + 5000);
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }



=> Start the bugs-api server

=> No change to the BugsApiTests code


=> Run the test and observe the "allure-results" folder is created

=> Open the terminal in the IntelliJ and run the below command

$ allure serve
(Open the Timeline tab to see the speed of the test cases)


=> Open "BugController.java" and replace the code with the below code
# We are reverting back to our original code

# BugController.java
package org.loonycorn.bugsapi.controller;

import org.loonycorn.bugsapi.model.Bug;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;

import java.util.*;
import java.time.LocalDateTime;
import java.util.stream.Collectors;

@RestController
public class BugController {
    private final List<Bug> bugs = new ArrayList<>();

    @GetMapping("/")
    public String welcome() {
        return "Welcome to the Bug Tracking API!";
    }

    @GetMapping("/bugs")
    public ResponseEntity<List<Bug>> getBugs(
            @RequestParam(required = false) String createdByContains,
            @RequestParam(required = false) Integer priority,
            @RequestParam(required = false) String severity,
            @RequestParam(required = false) Boolean completed,
            @RequestParam(required = false) String titleContains
    ) {

        List<Bug> filteredBugs = bugs.stream()
                .filter(bug -> createdByContains == null || bug.getCreatedBy().contains(createdByContains))
                .filter(bug -> priority == null || bug.getPriority().equals(priority))
                .filter(bug -> severity == null || bug.getSeverity().equals(severity))
                .filter(bug -> completed == null || bug.getCompleted().equals(completed))
                .filter(bug -> titleContains == null || bug.getTitle().contains(titleContains))
                .collect(Collectors.toList());

        return ResponseEntity.ok(filteredBugs);
    }

    @GetMapping("/bugs/{bugId}")
    public ResponseEntity<?> getBug(@PathVariable String bugId) {

        Bug bug = bugs.stream()
                .filter(b -> b.getBugId().equals(bugId))
                .findFirst()
                .orElse(null);

        if (bug != null) {
            return ResponseEntity.ok(bug);
        } else {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(Collections.singletonMap("error", "Bug not found"));
        }
    }

    @PostMapping("/bugs")
    public ResponseEntity<?> createBug(@RequestBody Bug bug) {
        bugs.add(bug);

        return ResponseEntity.status(HttpStatus.CREATED).body(bug);
    }

    @PutMapping("/bugs/{bugId}")
    public ResponseEntity<?> updateBug(@PathVariable String bugId, @RequestBody Bug updatedBug) {

        Bug bugToUpdate = bugs.stream()
                .filter(b -> b.getBugId().equals(bugId))
                .findFirst()
                .orElse(null);

        if (bugToUpdate != null) {
            bugToUpdate.setCreatedBy(updatedBug.getCreatedBy());
            bugToUpdate.setPriority(updatedBug.getPriority());
            bugToUpdate.setSeverity(updatedBug.getSeverity());
            bugToUpdate.setTitle(updatedBug.getTitle());
            bugToUpdate.setCompleted(updatedBug.getCompleted());
            bugToUpdate.setUpdatedOn(LocalDateTime.now());

            return ResponseEntity.ok(bugToUpdate);
        } else {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(Collections.singletonMap("error", "Bug not found"));
        }
    }

    @PatchMapping("/bugs/{bugId}")
    public ResponseEntity<?> patchBug(@PathVariable String bugId, @RequestBody Bug updatedBug) {
        Bug bugToUpdate = bugs.stream()
                .filter(b -> b.getBugId().equals(bugId))
                .findFirst()
                .orElse(null);

        if (bugToUpdate != null) {
            if (updatedBug.getCreatedBy() != null) {
                bugToUpdate.setCreatedBy(updatedBug.getCreatedBy());
            }
            if (updatedBug.getPriority() != null) {
                bugToUpdate.setPriority(updatedBug.getPriority());
            }
            if (updatedBug.getSeverity() != null) {
                bugToUpdate.setSeverity(updatedBug.getSeverity());
            }
            if (updatedBug.getTitle() != null) {
                bugToUpdate.setTitle(updatedBug.getTitle());
            }
            if (updatedBug.getCompleted() != null) {
                bugToUpdate.setCompleted(updatedBug.getCompleted());
            }
            bugToUpdate.setUpdatedOn(LocalDateTime.now());

            return ResponseEntity.ok(bugToUpdate);
        } else {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(Collections.singletonMap("error", "Bug not found"));
        }
    }

    @DeleteMapping("/bugs/{bugId}")
    public ResponseEntity<?> deleteBug(@PathVariable String bugId) {
        Bug bug = bugs.stream()
                .filter(b -> b.getBugId().equals(bugId))
                .findFirst()
                .orElse(null);

        if (bug != null) {
            bugs.remove(bug);

            Map<String, String> responseMessage = new HashMap<>();
            responseMessage.put("message", "Bug deleted");
            responseMessage.put("bug_id", bugId);

            return ResponseEntity.ok(responseMessage);
        } else {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(Collections.singletonMap("error", "Bug not found"));
        }
    }
}


=> Start the bugs-api server

=> Run the test and observe the "allure-results" folder is created

=> Open the terminal in the IntelliJ and run the below command

$ allure serve
(Open the Timeline tab to see the speed of the test cases)
(Now we can see the speed of the test cases in the Allure Report, compare the speed of the test cases before and after the delay)



################################
################################
################################
# https://stackoverflow.com/questions/49067297/how-does-allure-get-the-test-status-in-categories-json

# Now lets see how we can add categories to the Allure Report

# By default, there will be two categories of defects in an Allure report:
# Product defects (Tests that failed due to an issue in the product)
# Test defects (Broken tests)

=> Open "BugsTest.java" and in testGETRetrieveBugs, change this code to cause the test to fail

        response.then()
                .statusCode(200)
                .body("size()", equalTo(3));


=> Run the full test and observe the "allure-results" folder is created

=> Open the terminal in the IntelliJ and run the below command

$ allure serve
(Now we can see the categories of defects called Product defects in the Allure Report)


=> In "allure-results" folder create a new file called "categories.json" and add the below code

# categories.json
[
  {
    "name": "Test Issues",
    "matchedStatuses": ["failed"]
  }
]

=> Run the full test and observe the "allure-results" folder is created

=> Open the terminal in the IntelliJ and run the below command

$ allure serve
(Now we can see the categories of defects called "Test Issues" in the Allure Report)


=> Open "categories.json" and replace the code with the below code

# categories.json
[
  {
    "name": "Test Ignored",
    "matchedStatuses": ["skipped"]
  },
  {
    "name": "Problem in the API",
    "messageRegex": ".*Expected status code.* but was.*",
    "matchedStatuses": ["failed", "broken"]
  },
  {
    "name": "Problem in Test",
    "matchedStatuses": ["failed"]
  },
  {
    "name": "Passed",
    "messageRegex": ".*",
    "matchedStatuses": ["passed"]
  }
]


=> Run the full test and observe the "allure-results" folder is created

=> Our tests will still fail and we will still have skipped tests

=> Open the terminal in the IntelliJ and run the below command

$ allure serve
(Observe now we have 2 new categories called "Tests Ignored" and "Test Issues" in the Allure Report)

################################

=> Stop the bugs-api server

=> Open "BugsController.java" this one block of code

# NOTE: Instead of the endpoint bugs we are using bug

@PostMapping("/bug")
public ResponseEntity<?> createBug(@RequestBody Bug bug) {
    bugs.add(bug);

    return ResponseEntity.status(HttpStatus.CREATED).body(bug);
}


=> Start the bugs-api server


=> Open the "BugsApiTest.java" and replace this one block of code
# We are fixing it back to 2 from 3 in testGETRetrieveBugs


        response.then()
                .statusCode(200)
                .body("size()", equalTo(2));


=> Run the full test and observe the "allure-results" folder is created

=> Open the terminal in the IntelliJ and run the below command

$ allure serve
(Now we can see the categories of defects called "API Issues", "Test Issues" and "Tests Ignored" in the Allure Report)


################################
# Do this in background

=> Stop the bugs-api server
=> Open "BugsController.java" this one block of code (fix the API back)

@PostMapping("/bugs")
public ResponseEntity<?> createBug(@RequestBody Bug bug) {
bugs.add(bug);

return ResponseEntity.status(HttpStatus.CREATED).body(bug);
}

=> Start the server


