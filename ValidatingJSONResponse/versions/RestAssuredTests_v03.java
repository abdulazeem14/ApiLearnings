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
    public void testBody() {
        ResponseBody<?> responseBody = RestAssured
                .given()
                    .pathParam("id", 1)
                .when()
                    .get(STORE_USER_URL);

        JsonPath jsonPath = responseBody.jsonPath();

        assertThat(jsonPath.get("email"), equalTo("john@gmail.com"));
        assertThat(jsonPath.get("username"), equalTo("johnd"));

        assertThat(jsonPath.get("name.firstname"), equalTo("john"));
        assertThat(jsonPath.get("name.lastname"), equalTo("doe"));

        assertThat(jsonPath.get("address.city"), equalTo("kilcoole"));
        assertThat(jsonPath.get("address.street"), equalTo("new road"));
        assertThat(jsonPath.get("address.number"), equalTo(7682));

    }

}