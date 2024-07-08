package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.path.json.JsonPath;
import io.restassured.response.ResponseBody;
import org.testng.annotations.Test;

import java.util.Map;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_CATEGORIES_URL = "https://fakestoreapi.com/products/categories";

    @Test
    public void testBody() {
        RestAssured
                .get(STORE_CATEGORIES_URL)
                .then()
                    .body("$", hasItem("electronics"))
                    .body("$", hasItems("jewelery", "men's clothing", "electronics"))
                    .body("", contains(
                            "electronics", "jewelery", "men's clothing", "women's clothing"))
                    .body("", containsInAnyOrder(
                            "men's clothing", "women's clothing", "electronics", "jewelery"));
    }

}