package org.loonycorn.restassuredtests;

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
                    .statusCode(401);
    }


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
                    .statusCode(401);
    }

}
