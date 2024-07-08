package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class AuthenticationTests {

    private final String GITHUB_REPOS_URL = "https://api.github.com/user/repos";
    private final String GITHUB_TOKEN =
            "";

    @Test
    void createRepo() {
        String jsonString = "{\"name\": \"testrepo\"}";

        RestAssured
                .given()
                    .baseUri(GITHUB_REPOS_URL)
                    .body(jsonString)
                    .auth().oauth2(GITHUB_TOKEN)
                .when()
                    .post()
                .then()
                    .statusCode(201);
    }

}
