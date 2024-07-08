-----------------------------------------------
Validating XML response
-----------------------------------------------

# Go to

https://thetestrequest.com/

# Scroll to the bottom and see the XML API

# Click on

GET - /authors/1.xml

# Change URL and show

https://thetestrequest.com/authors/2.xml


-----------------------------------------------
# Set up our first test, basic querying of the URL (v01)

package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.testng.annotations.Test;

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
                    .statusCode(200);
    }

}

# Run and show

# Test that the body is not null


    @Test
    public void testXMLResponse() {
        RestAssured
                .given()
                    .accept(ContentType.XML)
                    .pathParam("id", 1)
                .get(AUTHORS_URL)
                .then()
                    .statusCode(200)
                    .body("hash", notNullValue());
    }

# Run and show

# Perform property tests as before


    @Test
    public void testXMLResponse() {
        RestAssured
                .given()
                    .accept(ContentType.XML)
                    .pathParam("id", 1)
                .get(AUTHORS_URL)
                .then()
                    .statusCode(200)
                    .body("hash", notNullValue())
                    .body("hash.name", equalTo("Karl Zboncak"))
                    .body("hash.email", equalTo("viva@keebler.biz"));
    }

# Run and show that things pass

# Can use rootPath as well


    @Test
    public void testXMLResponse() {
        RestAssured
                .given()
                    .accept(ContentType.XML)
                    .pathParam("id", 1)
                .get(AUTHORS_URL)
                .then()
                    .statusCode(200)
                    .body("hash", notNullValue())
                    .body("hash.name", equalTo("Karl Zboncak"))
                    .body("hash.email", equalTo("viva@keebler.biz"));
    }



-----------------------------------------------
# Testing an array of responses (v02)

# Go to this URL:

https://thetestrequest.com/authors.xml

# Now in IntelliJ we can test this array


    @Test
    public void testXMLResponse() {
        RestAssured
                .given()
                    .accept(ContentType.XML)
                .get(AUTHORS_URL)
                .then()
                    .statusCode(200)
                    .body("objects.object[0]", notNullValue())
                    .body("objects.object.id[0]", equalTo("1"))
                    .body("objects.object.name[0]", equalTo("Karl Zboncak"))
                    .body("objects.object.email[0]", equalTo("viva@keebler.biz"));
    }


# Run and show

# Can expand the tests


    @Test
    public void testXMLResponse() {
        RestAssured
                .given()
                    .accept(ContentType.XML)
                .get(AUTHORS_URL)
                .then()
                    .statusCode(200)
                    .body("objects.object[0]", notNullValue())
                    .body("objects.object.id[0]", equalTo("1"))
                    .body("objects.object.name[0]", equalTo("Karl Zboncak"))
                    .body("objects.object.email[0]", equalTo("viva@keebler.biz"))
                    .body("objects.object[1]", notNullValue())
                    .body("objects.object.id[1]", equalTo("2"))
                    .body("objects.object.name[1]", equalTo("Jeffie Wolf I"))
                    .body("objects.object.email[1]", equalTo("mike.kreiger@prohaska.biz"));
    }

# Run and show

# Can use rootPath


    @Test
    public void testXMLResponse() {
        RestAssured
                .given()
                    .accept(ContentType.XML)
                .get(AUTHORS_URL)
                .then()
                    .statusCode(200)
                    .rootPath("objects.object[0]")
                        .body("", notNullValue())
                        .body("id", equalTo("1"))
                        .body("name", equalTo("Karl Zboncak"))
                        .body("email", equalTo("viva@keebler.biz"))
                    .rootPath("objects.object[1]")
                        .body("", notNullValue())
                        .body("id", equalTo("2"))
                        .body("name", equalTo("Jeffie Wolf I"))
                        .body("email", equalTo("mike.kreiger@prohaska.biz"));
    }

# Run and show


# Can very properties as well


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

# Run and show




































































