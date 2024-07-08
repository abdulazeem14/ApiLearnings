package org.loonycorn.restassuredtests;

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

}
