package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.path.json.JsonPath;
import io.restassured.response.ResponseBody;
import org.testng.annotations.Test;

import java.util.Map;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_ELECTRONICS_URL = "https://fakestoreapi.com/products/category/electronics";

    @Test
    public void testBody() {
        RestAssured
                .get(STORE_ELECTRONICS_URL)
                .then()
                    .body("[0]", notNullValue())
                    .body("[2]", notNullValue());
    }

    @Test
    public void testListElementContents() {
        RestAssured
                .get(STORE_ELECTRONICS_URL)
                .then()
                .rootPath("[0]")
                    .body("id", equalTo(9))
                    .body("title", containsStringIgnoringCase("hard drive"))
                    .body("price", equalTo(64))
                    .body("rating.rate", lessThanOrEqualTo(5f))
                    .body("rating.count", greaterThan(200))
                .rootPath("[2]")
                    .body("id", equalTo(11))
                    .body("title", containsString("256GB SSD"))
                    .body("price", equalTo(109))
                    .body("rating.rate", lessThanOrEqualTo(5f))
                    .body("rating.count", greaterThan(300));
    }

    @Test
    public void testFieldContentsInLists() {
        RestAssured
                .get(STORE_ELECTRONICS_URL)
                .then()
                .body("id", hasItems(9, 12, 13, 14))
                .body("id", containsInAnyOrder(9, 12, 13, 14, 11, 10))
                .body("title", hasItem(containsString("SSD")))
                .body("image", everyItem(endsWith(".jpg")))
                .body("category", everyItem(equalTo("electronics")))
                .body("rating.rate", everyItem(allOf(greaterThan(0f), lessThan(5f))));
    }

}