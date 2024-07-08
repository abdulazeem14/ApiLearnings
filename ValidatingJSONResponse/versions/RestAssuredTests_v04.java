package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.path.json.JsonPath;
import io.restassured.response.ResponseBody;
import org.testng.annotations.Test;

import java.util.Map;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_USER_URL = "https://fakestoreapi.com/users/{id}";

    @Test
    public void testBody() {
        RestAssured
                .given()
                    .pathParam("id", 1)
                .when()
                    .get(STORE_USER_URL)
                .then()
                    .body("id", equalTo(1))
                    .body("email", equalTo("john@gmail.com"))
                    .body(containsStringIgnoringCase("zipcode"))
                    .body(allOf(containsString("name"), containsString("address")));
    }

}