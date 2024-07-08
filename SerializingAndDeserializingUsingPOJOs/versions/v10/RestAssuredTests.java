package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.loonycorn.restassuredtests.model.Product;
import org.loonycorn.restassuredtests.model.User;
import org.testng.annotations.Test;

import java.util.Arrays;
import java.util.List;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_PRODUCTS_URL = "https://fakestoreapi.com/products";

    @Test
    public void testBody() {

        Product product = new Product(
            "test product",
            13.5f,
            "lorem ipsum set",
            "https://i.pravatar.cc",
            "electronics"
        );

        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(product)
                .when()
                    .post(STORE_PRODUCTS_URL)
                .then()
                    .statusCode(200)
                    .body("id", notNullValue())
                    .body("title", equalTo(product.getTitle()))
                    .body("price", equalTo(product.getPrice()))
                    .body("description", equalTo(product.getDescription()))
                    .body("image", equalTo(product.getImage()))
                    .body("category", equalTo(product.getCategory()));
    }
}