package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String USERS_URL = "https://reqres.in/api/users?page=1";

    @Test
    public void testBody() {
        RestAssured
                .get(USERS_URL)
                .then()
                    .body("data.email[0]", response ->
                            containsStringIgnoringCase(response.body().jsonPath().get("data.first_name[0]")))
                    .body("data.email[0]", response ->
                            containsStringIgnoringCase(response.body().jsonPath().get("data.last_name[0]")));
    }

}