#################################
Awaitility in Rest Assured
#################################
# https://medium.com/@aswathyn/awaitility-handling-async-wait-in-automation-5066e20a1d12
# https://www.youtube.com/watch?v=0nwhX-Pvjm0
# https://shirishams.medium.com/replace-thread-sleep-6b12def3c2e1

=> Go and show "http://www.awaitility.org/"

# Open BugController.java in bug-api project and replace with the below code
# Only adding a random error in post and delete methods and there is a 70% chance of error in the post and delete

################################# (V1)
# In the bugs-api module make some changes to BugController


# Initialize the bug list to start at empty

    private final List<Bug> bugs = new ArrayList<>();


# Add a method which will cause certain APIs to return an error 70% of the time


    private boolean shouldReturnError() {
        return Math.random() < 0.7;
    }

# Add this as the first line of code to all APIs

        if (shouldReturnError()) {
            return ResponseEntity.internalServerError().build();
        }

getBugs()

getBug(bugId)    

createBug(bug)

updateBug(bug)

patchBug(bug)

deleteBug(bugId)

# Now run the BugApiApplication

# Go to

http://localhost:8080/

# Should work

# Go to

http://localhost:8080/bugs

# Will likely fail - keep refreshing till it succeeds



################################# (V1)

=> Open AwaitingTests.java in learning-rest-assured

# We have made the tests simple we are creating 1 get, 1 post, 1 update and delete all

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

public class AwaitingTests {

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

    @Test
    public void testPOSTCreateBug() {
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

    @Test(dependsOnMethods = "testPOSTCreateBug")
    public void testGETRetrieveBugs() {
        RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .body("size()", greaterThan(0));
    }


    @Test(dependsOnMethods = "testGETRetrieveBugs")
    public void testPUTUpdateBug() {
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

    @Test(dependsOnMethods = "testPUTUpdateBug")
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
    }

}


#################################

=> Now run come individual tests in this file

testPOSTCreateBug

testDELETEAllBugs

# They will likely fail

# Run all tests  (Observe the tests fails)

# Since we know that the post and delete methods have a 70% chance of error, we need to wait for the response to be successful
# We can use some kind of loop to keep polling the response until we get a successful response

################################# (V2)

# Make changes to AwaitingTests.java to use a polling method

import java.util.concurrent.TimeUnit;


# Add this method just below createResponseSpec()


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


# In testPOSTCreateBug() replace the POST with this


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


# Now run only this one test and wait for it to succeed
# Watch the console, you will see how many retries we have

----------------------------------

# Now let's add this to the next test

# testGETRetrieveBugs

        executeWithRetry(() -> {
            RestAssured
                    .get()
                    .then()
                        .statusCode(200)
                        .body("size()", greaterThan(0));
        });


# Now run only this one test and wait for it to succeed
# Watch the console, you will see how many retries we have

----------------------------------
# Now let's add this to the next test testPUTUpdateBug

# Replace all the code after we get the response specification


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

# Now run only this one test and wait for it to succeed
# Watch the console, you will see how many retries we have
# We will likely have 2 sets of retries

----------------------------------
# Now let's add this to the next test testDELETEAllBugs

# Change the entire code

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


# Now run only this one test and wait for it to succeed
# Watch the console, you will see how many retries we have
# We will likely have 2 sets of retries


#################################

=> Now run the entire suite AwaitingTests.java
(This should work)

# May have to run this multiple times to get this to work

# Look how complicated this was for use to implement. 
# We can make use of Awaitility to make this easier



################################# (V3)

# Go to

https://mvnrepository.com/

# Search for

awaitility

# Add the awaitility dependency in pom.xml

<dependency>
      <groupId>org.awaitility</groupId>
      <artifactId>awaitility</artifactId>
      <version>4.2.0</version>
      <scope>test</scope>
</dependency>

# Reload Maven project


--------------------------------
# Go to AwaitingTests.java

# Now let's rewrite the tests to use awaitility

# Delete this method

executeWithRetry

# Comment out all the methods except the first 

testPOSTCreateBug

# Go to AwaitingTests.java and set up this import first

import static org.awaitility.Awaitility.await;

import io.restassured.response.Response;
import io.restassured.response.ValidatableResponse;


# In testPOSTCreateBug replace the executeWithRetry with this

# The await will poll till true is returned 

# We will return true only when all tests pass and no exception for test failure is thrown

# Note that we should not be validating the response body till we get a 201

# This rewriting of code is not great - but awaitility makes retries easy (tradeoff)

# So long as we return false, awaitility will keep retrying till out timeout


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


# Run the suite, it has just this one test so it passes

--------------------------------
# Now let's update the next test testGETRetrieveBugs

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


# Run the suite, it has 2 tests and both pass


--------------------------------
# Now let's update the next test testPUTUpdateBug

# Place this after we get the response spec


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

# Run the suite, it has 3 tests and all pass


--------------------------------
# Now let's update the next test testDELETEAllBugs


# Update the whole function


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


# Run all tests and show, they should pass

# Can have failures because of our very high rate of error (even after retries the tests fail)




























