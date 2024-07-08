-----------------------------------------------
Basic operations using the Response object
-----------------------------------------------

# Set up a test (v01)

package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.testng.annotations.Test;

public class RestAssuredTests {

    @Test
    void peekTest() {
        Response response = RestAssured.get("https://httpbin.org/get");

        response.peek();
    }
}


# Note that get() returns an object of type response

# Run and show the response and headers are printed out

---------------------------------

# Add one more test

    @Test
    void prettyPeekTest() {
        Response response = RestAssured.get("https://httpbin.org/get");

        response.prettyPeek();
    }

# Run just this one test and show

---------------------------------

# Add tests for print() and prettyPrint()
# Only prints the body of the response

    @Test
    void printTest() {
        Response response = RestAssured.get("https://httpbin.org/get");

        response.print();
    }

    @Test
    void prettyPrintTest() {
        Response response = RestAssured.get("https://httpbin.org/get");

        response.prettyPrint();
    }


# IMPORTANT: Run each test individually and show


---------------------------------

# Change the code (v02)

    @Test
    void peekTest() {
        Response response = RestAssured.get("https://httpbin.org/get");

        Assert.assertTrue(response.peek() instanceof Response);
    }

    @Test
    void prettyPeekTest() {
        Response response = RestAssured.get("https://httpbin.org/get");

        Assert.assertTrue(response.prettyPeek() instanceof Response);
    }

    @Test
    void printTest() {
        Response response = RestAssured.get("https://httpbin.org/get");

        Assert.assertTrue(response.print() instanceof String);
    }

    @Test
    void prettyPrintTest() {
        Response response = RestAssured.get("https://httpbin.org/get");

        Assert.assertTrue(response.prettyPrint() instanceof String);
    }

# IMPORTANT: Run all the tests by click on Run next to the class

# Show everything passes


# Select the peek() function of the response and hit Cmd + B

# This will take us to the ResponseBody interface which has the 4 methods


---------------------------------
# Change the code (v03)


public class RestAssuredTests {

    private static final String URL = "https://httpbin.org/get";

    @Test
    void basicResponseTest() {
        Response response = RestAssured.get(URL);

        Assert.assertEquals(response.getStatusCode(), 200);
        Assert.assertEquals(response.getStatusLine(), "HTTP/1.1 200 OK");
        Assert.assertEquals(response.getContentType(), "application/json");
    }
}

# Run and show the test passes

# Show that there are alternate functions that give you the same access

    @Test
    void basicResponseTest() {
        Response response = RestAssured.get(URL);

        Assert.assertEquals(response.statusCode(), 200);
        Assert.assertEquals(response.statusLine(), "HTTP/1.1 200 OK");
        Assert.assertEquals(response.contentType(), "application/json");
    }

# Change one of the assertEquals so it fails

# Re-run and show


---------------------------------
# Change the code (v04)

# Can access the response body as well (here we're converting to a string which is not actually how we should be testing the body)


public class RestAssuredTests {

    private static final String URL = "https://httpbin.org/get";

    @Test
    void basicResponseBodyTest() {
        Response response = RestAssured.get(URL);

        ResponseBody responseBody = response.getBody();

        responseBody.peek();

        // "Host" header
        Assert.assertTrue(responseBody.asString().contains("httpbin.org"));

        // "Accept-Encoding" header
        Assert.assertTrue(responseBody.asString().contains("gzip,deflate"));
    }
}


# Show the response body in peek() 
# Tests should pass


# Change how body() is accessed

ResponseBody responseBody = response.body();


# Run and show, tests should pass


---------------------------------
# Test headers (v05)

package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.http.Headers;
import io.restassured.response.Response;
import org.testng.Assert;
import org.testng.annotations.Test;

public class RestAssuredTests {

    private static final String URL = "https://httpbin.org/get";

    @Test
    void basicResponseBodyTest() {
        Response response = RestAssured.get(URL);

        Headers headers = response.getHeaders();

        Assert.assertTrue(headers.hasHeaderWithName("Content-Type"));
        Assert.assertTrue(headers.hasHeaderWithName("Content-Length"));

        Assert.assertEquals(headers.get("Access-Control-Allow-Origin").getValue(), "*");
        Assert.assertEquals(headers.get("Server").getValue(), "gunicorn/19.9.0");
    }
}

# Run and show that the tests pass


---------------------------------
# Test headers (v06)
# Another way to access headers


    @Test
    void basicResponseBodyTest() {
        Response response = RestAssured.get(URL);

        Assert.assertEquals(response.getHeader("Access-Control-Allow-Origin"), "*");
        Assert.assertEquals(response.getHeader("Server"), "gunicorn/19.9.0");
        Assert.assertEquals(response.getHeader("Content-Length"), "323");

    }


# Convert the String to Integer

        Assert.assertEquals(Integer.parseInt(response.getHeader("Content-Length")), 323);

        
























