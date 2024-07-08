-----------------------------------------------
Logging in RestAssured
-----------------------------------------------


# Remove all directories from the previous demo (under resources, util)

# Keep the model/BugRequestBody.java file

# Show the structure before the start of the demo



# Start the BugApiApplication on port 8080 - we've gone back to the original port


# Set up a test class

RestAssuredLogging.java

# Code as below
# Note that we have gone back to having extra headers, also authentication
# They are not needed for the actual API server but will be useful in our demo


import io.restassured.RestAssured;
import io.restassured.authentication.BasicAuthScheme;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.builder.ResponseSpecBuilder;
import io.restassured.http.ContentType;
import io.restassured.specification.ResponseSpecification;
import org.loonycorn.restassuredtests.model.BugRequestBody;

import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredLogging {

    @BeforeSuite
    void setup() {
        RestAssured.baseURI = "http://localhost:8080";
        RestAssured.basePath = "bugs";

        BasicAuthScheme scheme = new BasicAuthScheme();
        scheme.setUserName("fakeuser");
        scheme.setPassword("fakepassword");

        RestAssured.authentication = scheme;

        RestAssured.requestSpecification = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .setAccept(ContentType.JSON)
                .addHeader("Cookie", "name=value; sessionid=123456789")
                .addHeader("Cache-Control", "no-cache")
                .addHeader("Referer", "https://example.com/previous-page")
                .build();
    }

    @Test
    public void testGETRetrieveBugs() {
        RestAssured
                .given()
                    .queryParam("severity", "medium")
                    .queryParam("completed", false)
                    .queryParam("createdByContains", "John")
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("severity", everyItem(equalTo("medium")))
                    .body("completed", everyItem(is(false)))
                    .body("createdBy", everyItem(containsString("John")));
    }

    @Test
    public void testPOSTCreateBug() {
        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 3, "High",
                "Cannot filter by category", false
        );

        ResponseSpecification responseSpec = new ResponseSpecBuilder()
                .expectBody("createdBy", equalTo(bug.getCreatedBy()))
                .expectBody("priority", equalTo(bug.getPriority()))
                .expectBody("severity", equalTo(bug.getSeverity()))
                .expectBody("title", equalToIgnoringCase(bug.getTitle()))
                .expectBody("completed", equalTo(bug.getCompleted()))
                .build();

        String bugId = RestAssured
                .given()
                    .body(bug)
                .when()
                    .post()
                .then()
                    .statusCode(201)
                    .spec(responseSpec)
                    .extract().path("bugId");

        System.out.println("Bug ID: " + bugId);

        RestAssured
                .given()
                    .pathParam("bug_id", bugId)
                .when()
                    .get("/{bug_id}")
                .then()
                    .statusCode(200)
                    .spec(responseSpec);
    }
}



-----------------------------------------------
# Let's first see how request logging works - v01
-----------------------------------------------


# For testGETRetrieveBugs add this after the given() in order to log the request

                    .log().method()

# Run only the current test and show method logged
------------

# Now change to (notice the chaining)

	.log().method().log().uri()


# Run only the current test and show method and URI logged
------------

# Now expand logging to

.log().method().log().uri().log().params()

# Note it logs all kinds of params (we only have query params)
------------

# Now let's log cookies

                    .log().cookies()

# Run and show
------------

# Now let's log headers

                    .log().headers()

# Run and show
------------


# Now let's log body

                    .log().body()


# There is no body() for the GET request


# Switch to the POST request to create bug

                    .log().body()

# Run the POST request to create bug - see the body in the console

# Continue in the POST request

# We can just log all the parameters for a request

                    .log().body()



-----------------------------------------------
# Now let's see how response logging works - v02
-----------------------------------------------

# Comment out the request logs

# For testGETRetrieveBugs add this after the then() in order to log the request
# Please note it is after the then()

                    .log().headers()


# Run and show
------------

# Change to log body


                    .log().body()


# Run and show
------------

# Change to log all


                    .log().all()

# Run and show that it logs headers and body
------------

# Change to log only if error

                    .log().ifError()

# Run, there should be no error so nothing is logged

# Now go to the BugController.java file

# Change the return value in getBugs()

	return ResponseEntity.internalServerError().build();

# Restart the server


# Now run the testGETRetrieveBugs() test again

# The response is an error and you can see the headers are logged

# Make sure you go back and fix the server to return the right thing

------------

# Change to log only if validation fails

                    .log().ifValidationFails()

# Run there should be no logs

# Change one of the validators (change to compare with severity "low")                    

# Run again - now you should see logs along with a validation failure

# Fix the validation

------------

# Can also log based on conditions on the status code

	.log().ifStatusCodeIsEqualTo(200)

# Run and show (it will match so there will be logs)

# More detailed conditions

                    .log().ifStatusCodeMatches(greaterThanOrEqualTo(200))


# Run and show (it will match so there will be logs)


------------

# Can configure a fail message (helps distinguish between test failures)


                    .onFailMessage("Something wrong with with retrieve bugs!")


# Change one of the validators (change to compare with severity "low")                    

# Run the test 

-----------------------------------------------
# Now let's configure logging for requests and responses - v02
-----------------------------------------------

# Remove all the extra log statements across the two tests

# Now to testPOSTCreateBug

# Add this after the given()

import static io.restassured.config.LogConfig.logConfig;
import static io.restassured.filter.log.LogDetail.HEADERS;


                    .config(RestAssured.config().logConfig(
                            logConfig().enableLoggingOfRequestAndResponseIfValidationFails(HEADERS)))


# Get the test to fail (change status code comparison)

# run and show HEADERS are logged for both requests and responses

# Change HEADERS -> ALL

# run and show ALL is logged for both requests and responses

-------------------

# You could set this configuration for the whole suite  as well

# Remove this configuration from this one test (comment out)

# Add this to setup()

RestAssured.enableLoggingOfRequestAndResponseIfValidationFails();

# Get testGETRetrieveBugs also to  (change status code)

# Now both tests will fail

# Run the whole suite - we get logs for both requests and responses

# Get both tests to pass

# Run and show no logs

























