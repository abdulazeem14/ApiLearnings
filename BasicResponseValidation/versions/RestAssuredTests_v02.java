package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.testng.Assert;
import org.testng.annotations.Test;

public class RestAssuredTests {

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

}
