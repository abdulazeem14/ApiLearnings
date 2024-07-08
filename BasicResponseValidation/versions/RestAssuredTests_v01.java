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

    @Test
    void prettyPeekTest() {
        Response response = RestAssured.get("https://httpbin.org/get");

        response.prettyPeek();
    }

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

}
