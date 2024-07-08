package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.loonycorn.restassuredtests.model.User;
import org.testng.annotations.Test;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_USER_URL = "https://fakestoreapi.com/users/{id}";

    @Test
    public void testBody() {
        User user = RestAssured
                .given()
                .pathParam("id", 3)
                .when()
                .get(STORE_USER_URL).as(User.class);

        assertThat(user.getId(), equalTo(3));
        assertThat(user.getEmailAddress(), equalTo("kevin@gmail.com"));
        assertThat(user.getUsername(), equalTo("kevinryan"));
        assertThat(user.getPhoneNumber(), equalTo("1-567-094-1345"));

        assertThat(user.getFirstname(), equalTo("kevin"));
        assertThat(user.getLastname(), equalTo("ryan"));

        assertThat(user.getAddress().getCity(), equalTo("Cullman"));
        assertThat(user.getAddress().getStreet(), equalTo("Frances Ct"));
        assertThat(user.getAddress().getNumber(), equalTo(86));
        assertThat(user.getAddress().getZipcode(), equalTo("29567-1452"));

    }
}