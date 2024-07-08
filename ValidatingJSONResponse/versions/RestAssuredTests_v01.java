package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.response.ResponseBody;
import org.testng.annotations.Test;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_USER_URL = "https://fakestoreapi.com/users/{id}";

    @Test
    public void testBodyAsString() {
        ResponseBody<?> response = RestAssured
                .given()
                    .pathParam("id", 1)
                .when()
                    .get(STORE_USER_URL);

        String responseString = response.asString();

        assertThat(responseString.contains("address"), equalTo(true));
        assertThat(responseString.contains("geolocation"), equalTo(true));
        assertThat(responseString.contains("id"), equalTo(true));
        assertThat(responseString.contains("email"), equalTo(true));
    }

}
