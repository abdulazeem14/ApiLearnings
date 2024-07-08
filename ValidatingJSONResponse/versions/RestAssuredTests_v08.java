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
                    .rootPath("data[0]")
                        .body("id", equalTo(1))
                        .body("first_name", equalTo("George"))
                .noRootPath()
                        .body("data.first_name[1]", equalTo("Janet"))
                        .body("data.email[1]", equalTo("janet.weaver@reqres.in"))
                        .body("data.last_name", hasItems("Holt", "Morris"))
                        .body("data.last_name", hasItems(startsWith("Ram")));
    }

}