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
                    .pathParam("id", 2)
                .when()
                    .get(STORE_USER_URL)
                .then()
                    .rootPath("address")
                        .body("city", equalTo("kilcoole"))
                        .body("street", equalTo("Lovers Ln"))
                        .body("number", equalTo(7267))
                        .body("zipcode", equalTo("12926-3874"))
                    .rootPath("address.geolocation")
                        .body("lat", equalTo("-37.3159"))
                        .body("long", equalTo("81.1496"))
                    .rootPath("name")
                        .body("firstname", equalTo("david"))
                        .body("lastname", equalTo("morrison"))
                    .noRootPath()
                        .body("email", matchesPattern("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"))
                        .body("phone", equalTo("1-570-236-7033"));

    }

}