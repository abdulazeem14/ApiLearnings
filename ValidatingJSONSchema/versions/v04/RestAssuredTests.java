package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.Test;

import static io.restassured.module.jsv.JsonSchemaValidator.matchesJsonSchemaInClasspath;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String USERS_URL = "https://reqres.in/api/users/{id}";

    @Test
    public void testSchemaValidation() {
        RestAssured
                .given()
                    .pathParam("id", 5)
                .get(USERS_URL)
                .then()
                    .body(matchesJsonSchemaInClasspath("user_schema.json"));
    }

}