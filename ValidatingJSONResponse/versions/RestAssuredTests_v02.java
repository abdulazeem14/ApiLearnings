package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import io.restassured.response.ResponseBody;
import org.testng.annotations.Test;

import java.util.Map;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_USER_URL = "https://fakestoreapi.com/users/{id}";

    @Test
    public void testBodyUsingJsonPath() {
        ResponseBody<?> responseBody = RestAssured
                .given()
                    .pathParam("id", 1)
                .when()
                    .get(STORE_USER_URL);

        JsonPath jsonPath = responseBody.jsonPath();

        Map<String, ?> bodyJson = jsonPath.get();
        System.out.println(bodyJson);

        Map<String, ?> addressJson = jsonPath.get("address");
        System.out.println(addressJson);

        Map<String, ?> geolocationJson = jsonPath.get("address.geolocation");
        System.out.println(geolocationJson);

        String lat = jsonPath.get("address.geolocation.lat");
        System.out.println(lat);

    }

}