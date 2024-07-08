package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String AUTHORS_URL = "https://thetestrequest.com/authors/{id}.xml";

    @Test
    public void testXMLResponse() {
        RestAssured
                .given()
                    .accept(ContentType.XML)
                    .pathParam("id", 1)
                .get(AUTHORS_URL)
                .then()
                    .statusCode(200)
                    .rootPath("hash")
                        .body("", notNullValue())
                        .body("name", equalTo("Karl Zboncak"))
                        .body("email", equalTo("viva@keebler.biz"));
    }

}