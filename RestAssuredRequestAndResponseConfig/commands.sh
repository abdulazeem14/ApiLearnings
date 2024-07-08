-----------------------------------------------
Rest Assured request and response config
-----------------------------------------------

-----------------------------------------------
Original code with many tests - v01
-----------------------------------------------

# Please note that all the extra headers are just that - extra headers not really needed but will help demonstrate what we're trying to do
# The the auth is also fake, not needed

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.loonycorn.restassuredtests.model.BugRequestBody;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredConfigurationTests {

    private static final String BUGS_URL = "http://localhost:8080";

    @Test
    public void testPOSTCreateBugOne(){

        BugRequestBody bug = new BugRequestBody(
                "Joseph Wang", 3, "High",
                "Cannot filter by category", false
        );

        String bugId = RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .contentType(ContentType.JSON)
                    .accept(ContentType.JSON)
                    .header("Cookie", "name=value; sessionid=123456789")
                    .header("Cache-Control", "no-cache")
                    .header("Referer", "https://example.com/previous-page")
                    .auth().basic("fakeuser", "fakepassword")
                    .body(bug)
                .when()
                    .post("/bugs")
                .then()
                    .statusCode(201)
                    .body("createdBy", equalTo(bug.getCreatedBy()))
                    .body("priority", equalTo(bug.getPriority()))
                    .body("severity", equalTo(bug.getSeverity()))
                    .body("title", equalToIgnoringCase(bug.getTitle()))
                    .body("completed", equalTo(bug.getCompleted()))
                    .extract().path("bugId");

        System.out.println("Bug ID: " + bugId);

        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .contentType(ContentType.JSON)
                    .accept(ContentType.JSON)
                    .header("Cookie", "name=value; sessionid=123456789")
                    .header("Cache-Control", "no-cache")
                    .header("Referer", "https://example.com/previous-page")
                    .auth().basic("fakeuser", "fakepassword")
                    .pathParam("bug_id", bugId)
                .when()
                    .get("/bugs/{bug_id}")
                .then()
                    .statusCode(200)
                    .body("createdBy", equalTo(bug.getCreatedBy()))
                    .body("priority", equalTo(bug.getPriority()))
                    .body("severity", equalTo(bug.getSeverity()))
                    .body("title", equalToIgnoringCase(bug.getTitle()))
                    .body("completed", equalTo(bug.getCompleted()));
    }

    @Test
    public void testPOSTCreateBugTwo() {

        BugRequestBody bug = new BugRequestBody(
                "Norah Jones", 0, "Critical",
                "Home page does not load", false
        );

        String bugId = RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .contentType(ContentType.JSON)
                    .accept(ContentType.JSON)
                    .header("Cookie", "name=value; sessionid=123456789")
                    .header("Cache-Control", "no-cache")
                    .header("Referer", "https://example.com/previous-page")
                    .auth().basic("fakeuser", "fakepassword")
                    .body(bug)
                .when()
                    .post("/bugs")
                .then()
                    .statusCode(201)
                    .body("createdBy", equalTo(bug.getCreatedBy()))
                    .body("priority", equalTo(bug.getPriority()))
                    .body("severity", equalTo(bug.getSeverity()))
                    .body("title", equalToIgnoringCase(bug.getTitle()))
                    .body("completed", equalTo(bug.getCompleted()))
                    .extract().path("bugId");

        System.out.println("Bug ID: " + bugId);

        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .contentType(ContentType.JSON)
                    .accept(ContentType.JSON)
                    .header("Cookie", "name=value; sessionid=123456789")
                    .header("Cache-Control", "no-cache")
                    .header("Referer", "https://example.com/previous-page")
                    .auth().basic("fakeuser", "fakepassword")
                    .pathParam("bug_id", bugId)
                .when()
                    .get("/bugs/{bug_id}")
                .then()
                    .statusCode(200)
                    .body("createdBy", equalTo(bug.getCreatedBy()))
                    .body("priority", equalTo(bug.getPriority()))
                    .body("severity", equalTo(bug.getSeverity()))
                    .body("title", equalToIgnoringCase(bug.getTitle()))
                    .body("completed", equalTo(bug.getCompleted()));
    }

    @Test(dependsOnMethods = { "testPOSTCreateBugOne", "testPOSTCreateBugTwo" })
    public void testGETTwoMoreBugsPresent() {

        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .contentType(ContentType.JSON)
                    .accept(ContentType.JSON)
                    .header("Cookie", "name=value; sessionid=123456789")
                    .header("Cache-Control", "no-cache")
                    .header("Referer", "https://example.com/previous-page")
                    .auth().basic("fakeuser", "fakepassword")
                .when()
                    .get("/bugs")
                .then()
                    .statusCode(200)
                    .body("size()", greaterThan(25));
    }
}


# Run teh tests and show they pass

# Select RestAssured and hit Cmd + B

# On lines 64 to 76 you can see the global variables that you can configure for RestAssure

# Explain the following

baseURI
basePath
port
rootPath

# and also

config
requestSpecification
responseSpecification


### Notes

# The config property in RestAssured allows you to configure various aspects of RestAssured's behavior. This includes settings related to HTTP requests, JSON or XML parsing, logging, and more. By customizing the config, you can alter how RestAssured processes your API requests and responses globally or for specific tests.

# For example, you can configure RestAssured to use a specific SSL configuration, increase timeouts, or enable detailed request and response logging for troubleshooting.

# A requestSpecification is a pre-defined set of request data in RestAssured that can be reused across multiple requests. This includes headers, query parameters, body content, cookies, and more. By using requestSpecification, you can create a template for your requests, which helps avoid repetitive code when you have multiple API calls that share common setup.

# You can define a requestSpecification and then use it with various HTTP methods (GET, POST, etc.), making your tests cleaner and more maintainable.

# Similar to requestSpecification, a responseSpecification defines expected data for a response that you can reuse across multiple tests. This could include expected status codes, headers, body content, etc. Using responseSpecification helps ensure consistency in how responses are validated and reduces duplication when the same validations apply to multiple responses.

-----------------------------------------------

# Now let's use some global variables (baseURI)

import org.testng.annotations.BeforeSuite;


    @BeforeSuite
    void setup() {
        RestAssured.baseURI = "http://localhost:8080";
    }


# Remove the BASE_URL variable

    private static final String BUGS_URL = "http://localhost:8080";

# Now remove the baseUri() call from every test

                    .baseUri(BASE_URL)



# Run all the tests and show they pass

-----------------------------------------------

# Now let's use some global variables (basePath)


    @BeforeSuite
    void setup() {
        RestAssured.baseURI = "http://localhost:8080";
        RestAssured.basePath = "bugs";
    }


# Now from every GET or POST remove the /bugs part

# IMPORTANT: Make sure you leave the /{bug_id} part



-----------------------------------------------

# Now let's use some global variables (authentication)


    @BeforeSuite
    void setup() {
        RestAssured.baseURI = "http://localhost:8080";
        RestAssured.basePath = "bugs";

        BasicAuthScheme scheme = new BasicAuthScheme();
        scheme.setUserName("fakeuser");
        scheme.setPassword("fakepassword");

        RestAssured.authentication = scheme;
    }


-----------------------------------------------

# Now let's set up the request specification

# In teh first test testPOSTCreateBugOne()

# Set up the request specification


        RequestSpecification requestSpec = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .setAccept(ContentType.JSON)
                .addHeader("Cookie", "name=value; sessionid=123456789")
                .addHeader("Cache-Control", "no-cache")
                .addHeader("Referer", "https://example.com/previous-page")
                .build();


# Replace all the headers with the spec

        String bugId = RestAssured
                .given()
                    .spec(requestSpec)
                    .body(bug)
                .when()    
                ...	

# Do the same in the second request in the same function

        RestAssured
                .given()
                    .spec(requestSpec)
                    .pathParam("bug_id", bugId)
                .when()
                ...    

# Run just the first test and show it passes

# Now comment out the one header in the request spec that is needed


        RequestSpecification requestSpec = new RequestSpecBuilder()
//                .setContentType(ContentType.JSON)
                .setAccept(ContentType.JSON)
                .addHeader("Cookie", "name=value; sessionid=123456789")
                .addHeader("Cache-Control", "no-cache")
                .addHeader("Referer", "https://example.com/previous-page")
                .build();

# Now run again - the test will fail

# Proves that the spec specifies all the headers for each request

-----------------------------------------------

# Move the request specification to the global variable so it is set for all requests

# Add this inside setup()


        RestAssured.requestSpecification = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .setAccept(ContentType.JSON)
                .addHeader("Cookie", "name=value; sessionid=123456789")
                .addHeader("Cache-Control", "no-cache")
                .addHeader("Referer", "https://example.com/previous-page")
                .build();


# Remove the spec() in the request that have this

# Remove the extra headers from all requests

# Run and everything should pass


-----------------------------------------------

# Set up the response spec, but we will have to do this per test as the bug information is specific to the test

# In testPOSTCreateBugOne add


        ResponseSpecification responseSpec = new ResponseSpecBuilder()
                .expectBody("createdBy", equalTo(bug.getCreatedBy()))
                .expectBody("priority", equalTo(bug.getPriority()))
                .expectBody("severity", equalTo(bug.getSeverity()))
                .expectBody("title", equalToIgnoringCase(bug.getTitle()))
                .expectBody("completed", equalTo(bug.getCompleted()))
                .build();

# For each of the requests (post)

                .then()
                    .statusCode(201)
                    .spec(responseSpec)
                    .extract().path("bugId");

# For the get

                .then()
                    .statusCode(200)
                    .spec(responseSpec);


# Run the test and show

# In testPOSTCreateBugTwo


        ResponseSpecification responseSpec = new ResponseSpecBuilder()
                .expectBody("createdBy", equalTo(bug.getCreatedBy()))
                .expectBody("priority", equalTo(bug.getPriority()))
                .expectBody("severity", equalTo(bug.getSeverity()))
                .expectBody("title", equalToIgnoringCase(bug.getTitle()))
                .expectBody("completed", equalTo(bug.getCompleted()))
                .build();



# For each of the requests (post)

                .then()
                    .statusCode(201)
                    .spec(responseSpec)
                    .extract().path("bugId");

# For the get

                .then()
                    .statusCode(200)
                    .spec(responseSpec);

# No change to the last test


# Now run the entire suite - everything should pass














































