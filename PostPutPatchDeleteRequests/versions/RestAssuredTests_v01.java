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

}