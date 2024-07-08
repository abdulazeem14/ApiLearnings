package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String POSTS_URL = "https://jsonplaceholder.typicode.com/posts";

    private static final String COMMENTS_URL = "https://jsonplaceholder.typicode.com/posts/{id}/comments";

    @Test
    public void testExtract() {
        Integer postId = RestAssured
                .get(POSTS_URL)
                .then()
                    .body("size()", equalTo(100))
                    .extract()
                    .path("id[2]");

        RestAssured
                .given()
                    .pathParam("id", postId)
                .when()
                    .get(COMMENTS_URL)
                .then()
                    .body("size()", equalTo(5));

    }

}