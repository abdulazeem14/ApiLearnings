package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.response.ValidatableResponse;
import org.testng.annotations.Test;

public class RestAssuredTests {

    private static final String URL = "https://httpbin.org/get";

    @Test
    void validatableResponseTest() {
        RestAssured.get(URL)
                .then()
                .statusCode(200)
                .statusLine("HTTP/1.1 200 OK")
                .contentType("application/json")
                .header("Server", "gunicorn/19.9.0")
                .header("Access-Control-Allow-Origin", "*")
                .header("Content-Length", "323");
    }

}
