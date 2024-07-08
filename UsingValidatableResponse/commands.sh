-----------------------------------------------
Using the Validatable Response
-----------------------------------------------

# The response object cannot be chained and cannot be used to validate
# the different parts of the response directly

# Chaining using Validatable Response (v01)

package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.Test;

public class RestAssuredTests {

    private static final String URL = "https://httpbin.org/get";

    @Test
    void validatableResponseTest() {
        RestAssured.get(URL)
                .statusCode(200)
                .statusLine("HTTP/1.1 200 OK")
                .contentType("application/json");
    }
}


# Run this, this will be a compile time error

# Add the then() after get()

        RestAssured.get(URL)
                .then()
                .statusCode(200)
                .statusLine("HTTP/1.1 200 OK")
                .contentType("application/json");

# Note that then() returns a ValidatableResponse

# Run and the test will pass

# Change

200 -> 500

# The test will fail

# Show the docs page for the ValidatableResponse

https://javadoc.io/doc/io.rest-assured/rest-assured/latest/io/restassured/response/ValidatableResponse.html

# Click through to the interface

https://javadoc.io/doc/io.rest-assured/rest-assured/latest/io/restassured/response/ValidatableResponseOptions.html

# Show that statusCode(), contentType() all return T i.e. the ValidatableResponseOptions


-----------------------------------------------
# Show how chaining is possible (v02)


    @Test
    void validatableResponseTest() {
        ValidatableResponse vResponse = RestAssured.get(URL)
                .then();
        
        vResponse = vResponse.statusCode(200);
        vResponse = vResponse.statusLine("HTTP/1.1 200 OK");
        vResponse = vResponse.contentType("application/json");
    }


# Now type this out

# Stop at the vResponse. and show the drop down options
# Select the header() option that compares strings

        vResponse = vResponse.header("Server", "gunicorn/19.9.0");

# Add one more

        vResponse = vResponse.header("Access-Control-Allow-Origin", "*");


# run and show

# Change one of the tests to fail

		vResponse = vResponse.header("Server", "gunicorn/20.9.0");

# Run and show the failure

-----------------------------------------------
# Write code using chaining (v03)



    @Test
    void validatableResponseTest() {
        RestAssured.get(URL)
                .then()
                .statusCode(200)
                .statusLine("HTTP/1.1 200 OK")
                .contentType("application/json")
                .header("Server", "gunicorn/19.9.0")
                .header("Access-Control-Allow-Origin", "*");
    }

# Run and show - things should pass


# Add one more header to test

                .header("Content-Length", "323");

# Note that we can only compare the header value as a string


-----------------------------------------------
# Use ContentType enum (v04)


# Start typing to change contentType()

ContentType.

# Show the options

# Pick JSON for this test

# Code should look like this


    @Test
    void validatableResponseTest() {
        RestAssured.get(URL)
                .then()
                .statusCode(200)
                .statusLine("HTTP/1.1 200 OK")
                .contentType(ContentType.JSON)
                .header("Server", "gunicorn/19.9.0")
                .header("Access-Control-Allow-Origin", "*");
    }































































