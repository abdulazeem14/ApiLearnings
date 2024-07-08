-----------------------------------------------
Authentication
-----------------------------------------------

# Behind the scenes in IntelliJ

# Clean up the project and remove all the stuff from the previous demo

# Clean up resources/, clean up model/ and utils/

# Create (can rename the old file)

AuthenticationTests.java

-----------------------------------------------
# go to 

https://httpbin.org/

# Expand the authentication section and show the different kinds of auth

# We will try the basic auth first


# Expand basic-auth and execute that URL

# Specify username and password in the text box

someuser

somepassword


# In the dialog that pops up - specify the same username and password


someuser

somepassword


# Show the success response

# Now change the username

someotheruser

somepassword


# Now type in something else in the alert box that pops up

someuser

somepassword


# Show the error response



-----------------------------------------------
Basic authentication on httpbin.org - v01
-----------------------------------------------

# Run this test

import io.restassured.RestAssured;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class AuthenticationTests {

    private final String BASIC_AUTH_URL = "https://httpbin.org/basic-auth/{user}/{password}";

    @Test
    void testBasicAuth_noAuth() {
        RestAssured
                .given()
                    .pathParam("user", "someuser")
                    .pathParam("password", "somepassword")
                .when()
                    .get(BASIC_AUTH_URL)
                .then()
                    .statusCode(200);
    }
}


# Run should fail, the return value is 401 unauthorized

# Change code to 401

.statusCode(401);

# Run the test - should pass

-----------------------------------------------

# When using "challenged basic authentication" REST Assured will not supply the credentials unless the server has explicitly asked for it. This means that REST Assured will make an additional request to the server in order to be challenged and then follow up with the same request once more but this time setting the basic credentials in the header.

# Add this test with authentication

    @Test
    void testBasicAuth_withAuth() {
        RestAssured
                .given()
                    .pathParam("user", "someuser")
                    .pathParam("password", "somepassword")
                    .auth().basic("someuser", "somepassword")
                .when()
                    .get(BASIC_AUTH_URL)
                .then()
                    .statusCode(200)
                    .body("authenticated", equalTo(true))
                    .body("user", equalTo("someuser"));
    }

# Run this test and show that this passes


-----------------------------------------------

# Run with preemptive auth

    @Test
    void testBasicAuth_withPreemptiveAuth() {
        RestAssured
                .given()
                    .pathParam("user", "someuser")
                    .pathParam("password", "somepassword")
                    .auth().preemptive().basic("someuser", "somepassword")
                .when()
                    .get(BASIC_AUTH_URL)
                .then()
                    .statusCode(200)
                    .body("authenticated", equalTo(true))
                    .body("user", equalTo("someuser"));
    }

# Run and show test passes


-----------------------------------------------
# Run with wrong auth
# Try with status code 200 first


    @Test
    void testBasicAuth_withWrongeAuth() {
        RestAssured
                .given()
                    .pathParam("user", "someuser")
                    .pathParam("password", "somepassword")
                    .auth().preemptive().basic("someotheruser", "somepassword")
                .when()
                    .get(BASIC_AUTH_URL)
                .then()
                    .statusCode(200);
    }

# This should give an error

# Change status code to 401 and the test should pass

                    .statusCode(401);




-----------------------------------------------
Digest authentication on httpbin.org - v02
-----------------------------------------------

# go to 

https://httpbin.org/

# Expand the authentication section 

# Select the digest auth

# Expand digest-auth and execute that URL

# Specify qop, username and password in the text box

auth

someuser

somepassword


# In the dialog that pops up - specify the same username and password


someuser

somepassword


# Show the success response

# Now change the username

someotheruser

somepassword


# Now type in something else in the alert box that pops up

someuser

somepassword


# Show the error response

# Change the qop

auth-int

someuser

somepassword


# Enter the right username and password and show the response

# NOTE
# Currently only "challenged digest authentication" is supported. Example:


# Replace test with


    private final String DIGEST_AUTH_URL = "https://httpbin.org/digest-auth/{qop}/{user}/{password}";

    @Test
    void testDigestAuth_noAuth() {
        RestAssured
                .given()
                    .pathParam("qop", "auth")
                    .pathParam("user", "someuser")
                    .pathParam("password", "somepassword")
                .when()
                    .get(DIGEST_AUTH_URL)
                .then()
                    .statusCode(401);
    }


# Run and should pass

-----------------------------------------------

# Add test


    @Test
    void testDigestAuth_withAuth() {
        RestAssured
                .given()
                    .pathParam("qop", "auth")
                    .pathParam("user", "someuser")
                    .pathParam("password", "somepassword")
                    .auth().digest("someuser", "somepassword")
                .when()
                    .get(DIGEST_AUTH_URL)
                .then()
                    .statusCode(200)
                    .body("authenticated", equalTo(true))
                    .body("user", equalTo("someuser"));
    }

# Run and should pass

-----------------------------------------------

# Test with wrong password


    @Test
    void testDigestAuth_withWrongAuth() {
        RestAssured
                .given()
                    .pathParam("qop", "auth")
                    .pathParam("user", "someuser")
                    .pathParam("password", "somepassword")
                    .auth().digest("someuser", "wrongpassword")
                .when()
                    .get(DIGEST_AUTH_URL)
                .then()
                    .statusCode(200);
    }

# Run and should fail

# Fix the statusCode to

401

# Run and show it passed


-----------------------------------------------
Oauth1 on Postman Echo - v03
-----------------------------------------------

# Go to

https://postman-echo.com

# Show what postman-echo is all about

# Expand the Authentication methods section and show the different endpoints with different authentication

# Click on each authentication type

# Specifically focus on Oauth1

# After seeing how it works - click on Open Request

# This will open up the Postman Workspace

# Click on send - it will ask you to create a Fork

# Click on "Create a fork" and sign in 

# Now in your collection - click on send and show that the request succeeds

# Click on this tab

Authorization

# Show the consumer key and consumer secret - we will use this to make our request


# Back to IntelliJ


# Set up the test

# 4 inputs to Oauth1 

# Consumer Key
# Consumer Secret
# Access Token
# Token Secret


import io.restassured.RestAssured;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class AuthenticationTests {

    private final String OAUTH1_URL = "https://postman-echo.com/oauth1";

    @Test
    void testOauth1_withAuth() {
        RestAssured
                .given()
                    .auth().oauth("RKCGzna7bv9YD57c", "D+EdQ-gs$-%@2Nu7", "", "")
                .when()
                    .get(OAUTH1_URL)
                .then()
                    .statusCode(200)
                    .body("status", equalTo("pass"))
                    .body("message", equalTo("OAuth-1.0a signature verification was successful"));
    }

}


# Run and show that it passes

# Add this test (added an extra "e" to consumer key and consumer secret)

    @Test
    void testOauth1_withWrongAuth() {
        RestAssured
                .given()
                    .auth().oauth("RKCGzna7bv9YD57ce", "D+EdQ-gs$-%@2Nu7e", "", "")
                .when()
                    .get(OAUTH1_URL)
                .then()
                    .statusCode(401);
    }


# Run and show that it passes


-----------------------------------------------
Oauth2 on Github - v04
-----------------------------------------------

# Go to 

https://github.com/

# Login using 

loonytest

# Click on the account profile at the top right 

# Go to "Your repositories" and show the page

# Now let's write a test to use the API to create a repo


import io.restassured.RestAssured;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class AuthenticationTests {

    private final String GITHUB_REPOS_URL = "https://api.github.com/user/repos";

    @Test
    void createRepo() {
        String jsonString = "{\"name\": \"testrepo\"}";

        RestAssured
                .given()
                    .baseUri(GITHUB_REPOS_URL)
                    .body(jsonString)
                .when()
                    .post()
                .then()
                    .statusCode(201);
    }


}


# Run the test - should give a 401 unauthorized

# Go to the GitHub page

Account profile on the top right -> Settings -> Developer Settings

# Create a personal access token

loony-api-access

# Generate token and copy it over

# Update test



public class AuthenticationTests {

    private final String GITHUB_REPOS_URL = "https://api.github.com/user/repos";
    private final String GITHUB_TOKEN =
            "";

    @Test
    void createRepo() {
        String jsonString = "{\"name\": \"testrepo\"}";

        RestAssured
                .given()
                    .baseUri(GITHUB_REPOS_URL)
                    .body(jsonString)
                    .auth().oauth2(GITHUB_TOKEN)
                .when()
                    .post()
                .then()
                    .statusCode(201);
    }

}


# Run test - should pass

# Go to "Your repositories" and see the new repo created



-----------------------------------------------
Using authorization on a real site - v05
-----------------------------------------------

# > Open and show this url 

https://bookstore.toolsqa.com/

# Now lets use the bookstore api to demonstrate authentication

# Try out this request on the site

# Add new request

Get Books

/BookStore/v1/Books

# Execute and show the response

# Works without authentication

# Try another one

Get Book

/BookStore/v1/Book

ISBN=9781491904244

# Again works without authentication

# Try adding a book to a user

POST /BookStore/v1/Book

# Just execute and show you get an unauthorized error

-----------------------------------------------
# Create a user on the Swagger UI

# Go to 

POST Account/v1/User

# Specify this

{
  "userName": "loonyuser1000",
  "password": "Password@123"
}


# Get the userId and username and store it somewhere


-----------------------------------------------


# Set up the first test on IntelliJ


import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class AuthenticationTests {

    private final String BASE_URL = "https://bookstore.toolsqa.com/";

    private String userId = "";

    @Test
    void createUser() {
        String jsonString = "{\"userName\": \"loonyuser2001\", \"password\": \"Password@123\"}";

        userId = RestAssured
                .given()
                    .baseUri(BASE_URL)
                    .accept(ContentType.JSON)
                    .contentType(ContentType.JSON)
                    .body(jsonString)
                .when()
                    .post("/Account/v1/User")
                .then()
                    .statusCode(201)
                    .body("userID", notNullValue())
                    .body("username", equalTo("loonyuser2001"))
                    .extract().path("userID");

        System.out.println("User ID: " + userId);
    }
}


# The first time this will run through successfully

# Run the test again - it will fail with a 406 (user already exists)

-----------------------------------------------

# Fix the test in this way

import java.util.Random;


    private String userId = "";
    private String username = "";

    @Test
    void createUser() {
        username = "loonyuser" + new Random().nextInt(1000000);
        System.out.println("Username: " + username);

        String jsonString = String.format("{\"userName\": \"%s\", \"password\": \"Password@123\"}", username);

        userId = RestAssured
                .given()
                    .baseUri(BASE_URL)
                    .accept(ContentType.JSON)
                    .contentType(ContentType.JSON)
                    .body(jsonString)
                .when()
                    .post("/Account/v1/User")
                .then()
                    .statusCode(201)
                    .body("userID", notNullValue())
                    .body("username", equalTo(username))
                    .extract().path("userID");

        System.out.println("User ID: " + userId);
    }

# Run the test and this should pass

# The console output will give us the username and the user id

# Run the test again and it should pass

# The console will have a different username and password


-----------------------------------------------
# Now add a book to the user

# Go to the Swagger UI

# Expand the 

POST BookStore/v1/Books

# Show the structure of the request and the structure of the response

# Don't need to make any request

# Add this code to the test case
# Notice that we have not authenticated ourselves



    @Test(dependsOnMethods = "createUser")
    void addBookToUser() {
        String jsonString = String.format(
                "{\"userId\": \"%s\", \"collectionOfIsbns\": [{\"isbn\": \"9781593275846\"}]}", userId);

        RestAssured
                .given()
                    .baseUri(BASE_URL)
                    .accept(ContentType.JSON)
                    .contentType(ContentType.JSON)
                .body(jsonString)
                .when()
                    .post("BookStore/v1/Books")
                .then()
                .statusCode(201)
                .body("userID", equalTo(userId))
                .body("username", equalTo(username))
                .body("books.size()", equalTo(1))
                .body("books.isbn", hasItem(equalTo("9781593275846")))
                .extract().path("userID");
    }


# Run the entire test suite

# The second test should fail

Expected status code <201> but was <401>.


# Now add the authentication


                    .auth().preemptive().basic(username, "Password@123")

# The request becomes

        RestAssured
                .given()
                    .baseUri(BASE_URL)
                    .accept(ContentType.JSON)
                    .contentType(ContentType.JSON)
                    .auth().preemptive().basic(username, "Password@123")
                    .body(jsonString)
                .when()
                    .post("BookStore/v1/Books")
                .then()
                .statusCode(201)
                .body("books[0].isbn", equalTo("9781593275846"));


# Run the entire suite - things should pass


-----------------------------------------------
# Now retrieve books for user and check
# Status code 204 - no content


    @Test(dependsOnMethods = "getBooksForUser_expectOne")
    void deleteBooksForUser() {
        RestAssured
                .given()
                    .baseUri(BASE_URL)
                    .accept(ContentType.JSON)
                    .contentType(ContentType.JSON)
                    .queryParam("UserId", userId)
                    .auth().preemptive().basic(username, "Password@123")
                .when()
                    .delete("BookStore/v1/Books")
                .then()
                    .statusCode(204);
    }


# Run the entire suite - things should pass


-----------------------------------------------
# Now delete all books for user
# Status code 204 - no content



    @Test(dependsOnMethods = "getBooksForUser_expectOne")
    void deleteBooksForUser() {
        RestAssured
                .given()
                    .baseUri(BASE_URL)
                    .accept(ContentType.JSON)
                    .contentType(ContentType.JSON)
                    .queryParam("UserId", userId)
                    .auth().preemptive().basic(username, "Password@123")
                .when()
                    .delete("BookStore/v1/Books")
                .then()
                    .statusCode(204);
    }

# Run the entire suite - things should pass


-----------------------------------------------
# Now check that there are no books for a user



    @Test(dependsOnMethods = "deleteBooksForUser")
    void getBooksForUser_expectZero() {
        RestAssured
                .given()
                    .baseUri(BASE_URL)
                    .accept(ContentType.JSON)
                    .contentType(ContentType.JSON)
                    .pathParam("userId", userId)
                    .auth().preemptive().basic(username, "Password@123")
                .when()
                    .get("Account/v1/User/{userId}")
                .then()
                    .statusCode(200)
                    .body("books.size()", equalTo(0));
    }


# Run the entire suite - things should pass


# IMPORTANT: Copy over the last username and user id - we will need it for the next demo



