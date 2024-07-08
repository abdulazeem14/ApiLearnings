package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String AUTHORS_URL = "https://thetestrequest.com/authors.xml";

    @Test
    public void testXMLResponse() {
        RestAssured
                .given()
                .accept(ContentType.XML)
                .get(AUTHORS_URL)
                .then()
                .statusCode(200)
                .body("objects.object.name", hasItem("Dede Tillman"))
                .body("objects.object.id", containsInAnyOrder("5", "3", "2", "1", "4"))
                .body("objects.object.avatar", everyItem(endsWith("set1")));
    }
}