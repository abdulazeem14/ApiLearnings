-----------------------------------------------
Post, Put, Patch, Delete requests
-----------------------------------------------



----------------------------------------
# HEAD and OPTIONS request

package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String URL = "https://httpbin.org/";

    @Test
    public void testHEADEmptyBody() {
        RestAssured
                .head(URL)
                .then()
                .statusCode(200)
                .body(emptyOrNullString());
    }

}


# Run and show

# Add test for options


    @Test
    public void testOPTIONSEmptyBody() {
        RestAssured
                .options(URL)
                .peek()
                .then()
                .statusCode(200)
                .header("Allow", allOf(
                        containsString("OPTIONS"),
                        containsString("GET"),
                        containsString("HEAD"))
                )
                .header("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, PATCH, OPTIONS")
                .body(emptyOrNullString());
    }

# Run and show


----------------------------------------
# POST request with a string (v02)

# Make sure the BugApplicationApi is running (switch to the file and start it)


# Come to the tests RestAssuredTests.java

package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String BUGS_URL = "http://localhost:8090/bugs";

    @Test
    public void testPOSTCreateBug() {
        String bugBodyJson = "{\n" +
                "    \"createdBy\": \"Kim Doe\",\n" +
                "    \"priority\": 2 ,\n" +
                "    \"severity\": \"Critical\",\n" +
                "    \"title\": \"Database Connection Failure\",\n" +
                "    \"completed\": false\n" +
                "}";

        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(bugBodyJson)
                .when()
                    .post(BUGS_URL)
                .then()
                    .statusCode(201);
    }

}


--------
### Notes

# RestAssured with its Behavior-Driven Development (BDD) approach uses a domain-specific language (DSL) to describe the behavior of an HTTP-based service or application in a readable and understandable format. This approach encourages collaboration between developers, QA, and non-technical or business participants in a software project. The given(), when(), and then() methods are key components of this DSL, making your tests more readable and writing them feels like describing features in plain language. Let's break down each part:

# given()
# Purpose: The given() method is where you define the preconditions of your test. It's all about setting up the request before making the actual call to the API. This includes configuring the request headers, query parameters, body, cookies, and any authentication required.

# when()
# Purpose: The when() method is where you specify the action, typically the HTTP method and the endpoint URL. This part is crucial as it defines the interaction with the API under test, such as a GET to retrieve data, POST to create, PUT to update, etc.

# then()
# Purpose: The then() method is where you define the assertions to validate the response from the API. This could include checking status codes, response content, headers, or the execution time. It's the verification step to ensure the API behaves as expected given the defined preconditions and actions.

-------



# Run the test and show that it passes

# Switch to the browser

http://localhost:8090/bugs


# One new bug should have been created


# Expand the test for the body()


        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(bugBodyJson)
                .when()
                    .post(BUGS_URL)
                .then()
                    .statusCode(201)
                .body("createdBy", equalTo("Kim Doe"),
                      "priority", equalTo(2),
                      "severity", equalTo("Critical"),
                      "title", equalTo("Database Connection Failure"),
                      "completed", equalTo(false)
                );


# Run and show

# Switch to the browser

http://localhost:8090/bugs

# There should be 2 bugs with the same contents


-------

# Just switch to BugApplicationApi and restart the server


# Switch to the browser

http://localhost:8090/bugs


# There should be no bugs

# Switch back to the RestAssuredTests


# Add this just after creating the bug in the same test
# We're retrieving the list of bugs and checking to see if our bug is in there
# Not a great way to do this

       RestAssured
                .given()
                    .contentType(ContentType.JSON)
                .when()
                    .get(BUGS_URL)
                .then()
                    .statusCode(200)
                    .body("createdBy", hasItem("Kim Doe"))
                    .body("priority", hasItem(2))
                    .body("severity", hasItem("Critical"))
                    .body("priority", hasItem(equalToIgnoringCase("database connection failure")));


-------------

# Just switch to BugApplicationApi and restart the server

# Set up two tests - one depending on the other

# Still not great since the second test still checks withing a collection
# But we know how we can use test dependencies


    @Test
    public void testPOSTCreateBug() {
        String bugBodyJson = "{\n" +
                "    \"createdBy\": \"Kim Doe\",\n" +
                "    \"priority\": 2 ,\n" +
                "    \"severity\": \"Critical\",\n" +
                "    \"title\": \"Database Connection Failure\",\n" +
                "    \"completed\": false\n" +
                "}";


        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(bugBodyJson)
                .when()
                    .post(BUGS_URL)
                .then()
                    .statusCode(201)
                    .body("createdBy", equalTo("Kim Doe"),
                            "priority", equalTo(2),
                            "severity", equalTo("Critical"),
                            "title", equalTo("Database Connection Failure"),
                            "completed", equalTo(false)
                    );
    }


    @Test(dependsOnMethods = { "testPOSTCreateBug" })
    public void testGETCreatedBug() {
        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                .when()
                    .get(BUGS_URL)
                .then()
                    .statusCode(200)
                    .body("createdBy", hasItem("Kim Doe"))
                    .body("priority", hasItem(2))
                    .body("severity", hasItem("Critical"))
                    .body("title", hasItem(equalToIgnoringCase("database connection failure")));
    }


# Run the entire class

# Should pass

# Switch to the browser
http://localhost:8090/bugs

# There should be one bug


----------------------------------------
# Verify post request using extract (API chaining) (v03)

# Restart the BugApplicationApi


# Update the code

public class RestAssuredTests {

    private static final String BUGS_URL = "http://localhost:8090/bugs";

    @Test
    public void testPOSTCreateBug() {
        String bugBodyJson = "{\n" +
                "    \"createdBy\": \"Kim Doe\",\n" +
                "    \"priority\": 2 ,\n" +
                "    \"severity\": \"Critical\",\n" +
                "    \"title\": \"Database Connection Failure\",\n" +
                "    \"completed\": false\n" +
                "}";

        String bugId = RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(bugBodyJson)
                .when()
                    .post(BUGS_URL)
                .then()
                    .statusCode(201)
                    .body("createdBy", equalTo("Kim Doe"),
                            "priority", equalTo(2),
                            "severity", equalTo("Critical"),
                            "title", equalTo("Database Connection Failure"),
                            "description", equalTo(false)
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
                    .body("createdBy", equalTo("Kim Doe"))
                    .body("priority", equalTo(2))
                    .body("severity", equalTo("Critical"))
                    .body("title", equalToIgnoringCase("database connection failure"))
                    .body("completed", equalTo(false));

    }

}


# Run and show that this passes


# Switch to the browser
http://localhost:8090/bugs

# There should be one bug and the ID should match what was printed on the console


# IMPORTANT: Come back to the test and change something to make the test fail
# Just to show that the test is actually testing something



----------------------------------------
# Use an object mapper to set up the JSON (v04)


# Go to pom.xml 

# Show that we already have the Jackson databind dependency

# Update the test to use the object mapper


package org.loonycorn.restassuredtests;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String BUGS_URL = "http://localhost:8090/bugs";

    @Test
    public void testPOSTCreateBug() {
        String bugBodyJson = null;

        ObjectMapper objectMapper = new ObjectMapper();
        ObjectNode bug = objectMapper.createObjectNode();

        bug.put("createdBy", "Joseph Wang");
        bug.put("priority", 3);
        bug.put("severity", "High");
        bug.put("title", "Cannot filter by category");
        bug.put("completed", false);

        try {
            bugBodyJson = objectMapper.writeValueAsString(bug);
        } catch (Exception e) {
            e.printStackTrace();
        }

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

}


# Run and show that things all pass


----------------------------------------
# Create 2 bugs and test GET we have two bugs (v05)

# Restart the BugApplicationApi server - IMPORTANT


# Set up the code as below


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

}


# Run and show all pass

# Go to the browser

http://localhost:8090/bugs

# Show the two bugs created


----------------------------------------
# Use PUT to update bug (v06)

# DO NOT restart the BugsApplicationApi server



# Add yet another test

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


# IMPORTANT
# Remove the "depends" in the Test annotation

# Run only the update test

# Add the "depends" back


# Go to the browser

http://localhost:8090/bugs

# Show the updated bug


----------------------------------------
# Use PUT to update bug (v07)

# DO NOT restart the BugsApplicationApi server



# Add yet another test


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


# IMPORTANT
# Remove the "depends" in the Test annotation

# Run only the update test

# Add the "depends" back


# Go to the browser

http://localhost:8090/bugs

# Show the updated bug

----------------------------------------
# Use DELETE to delete bug (v08)

# DO NOT restart the BugsApplicationApi server



# Add yet another test

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


# IMPORTANT
# Remove the "depends" in the Test annotation

# Run only the update test

# Add the "depends" back


# Go to the browser

http://localhost:8090/bugs

# Show that we have just one bug


------------------------------
# Now one last time

# Restart the BugsApplicationApi server

# Run the entire test suite

# Everything should pass








