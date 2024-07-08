package org.loonycorn.restassuredtests;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.loonycorn.restassuredtests.model.User;
import org.testng.annotations.Test;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_USER_URL = "https://fakestoreapi.com/users/{id}";

    @Test
    public void testBody() throws JsonProcessingException {
        Response response = RestAssured
                .given()
                    .pathParam("id", 3)
                .when()
                    .get(STORE_USER_URL)
                .then()
                    .extract().response();

        ObjectMapper objectMapper = new ObjectMapper();
        User user = objectMapper.readValue(response.asString(), User.class);

        assertThat(user.getId(), equalTo(3));
        assertThat(user.getEmailAddress(), equalTo("kevin@gmail.com"));
        assertThat(user.getUsername(), equalTo("kevinryan"));
        assertThat(user.getPhoneNumber(), equalTo("1-567-094-1345"));
    }
}