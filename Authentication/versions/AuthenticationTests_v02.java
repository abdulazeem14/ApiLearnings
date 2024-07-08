package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class AuthenticationTests {

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
                    .statusCode(401);
    }

}
