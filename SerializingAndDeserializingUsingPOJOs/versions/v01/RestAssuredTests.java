package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_USER_URL = "https://fakestoreapi.com/users/{id}";

    @Test
    public void testBody() {
        RestAssured
                .given()
                    .pathParam("id", 3)
                .when()
                    .get(STORE_USER_URL)
                .then()
                    .body("id", equalTo(3))
                    .body("email", equalTo("kevin@gmail.com"))
                    .body("username", equalTo("kevinryan"))
                    .body("address.city", equalTo("Cullman"))
                    .body("address.street", equalTo("Frances Ct"))
                    .body("address.number", equalTo(86))
                    .body("address.zipcode", equalTo("29567-1452"))
                    .body("address.geolocation.lat", equalTo("40.3467"))
                    .body("address.geolocation.long", equalTo("-30.1310"))
                    .body("name.firstname", equalTo("kevin"))
                    .body("name.lastname", equalTo("ryan"));
    }
}