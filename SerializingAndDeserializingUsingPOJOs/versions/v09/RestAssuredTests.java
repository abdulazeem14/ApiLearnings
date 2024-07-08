package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.loonycorn.restassuredtests.model.User;
import org.testng.annotations.Test;

import java.util.Arrays;
import java.util.List;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_USERS_URL = "https://fakestoreapi.com/users/";

    @Test
    public void testBody() {
        List<User> users = Arrays.asList(RestAssured
                .get(STORE_USERS_URL).as(User[].class));

        assertThat(users.size(), equalTo(10));

        assertThat(users.get(2).getEmailAddress(), equalTo("kevin@gmail.com"));
        assertThat(users.get(2).getUsername(), equalTo("kevinryan"));
        assertThat(users.get(2).getPhoneNumber(), equalTo("1-567-094-1345"));

        assertThat(users.get(2).getFirstname(), equalTo("kevin"));
        assertThat(users.get(2).getLastname(), equalTo("ryan"));

        assertThat(users.get(2).getAddress().getCity(), equalTo("Cullman"));
        assertThat(users.get(2).getAddress().getStreet(), equalTo("Frances Ct"));
        assertThat(users.get(2).getAddress().getNumber(), equalTo(86));
        assertThat(users.get(2).getAddress().getZipcode(), equalTo("29567-1452"));

    }
}