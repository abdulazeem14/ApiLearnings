package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.testng.annotations.Test;

import java.util.Random;

import static org.hamcrest.Matchers.*;

public class AuthenticationTests {

    private final String BASE_URL = "https://bookstore.toolsqa.com/";

    private String userId = "";
    private String username = "";

    @Test
    void createUser() {
        username = "loonyuser" + new Random().nextInt(1000000);
        System.out.println("Username: " + username);

        String jsonString = String.format("{\"userName\": \"%s\", \"password\": \"Password@123\"}", username);

        userId = RestAssured
                .given()
                    .baseUri(BASE_URL)
                    .accept(ContentType.JSON)
                    .contentType(ContentType.JSON)
                    .body(jsonString)
                .when()
                    .post("/Account/v1/User")
                .then()
                    .statusCode(201)
                    .body("userID", notNullValue())
                    .body("username", equalTo(username))
                    .extract().path("userID");

        System.out.println("User ID: " + userId);
    }

    @Test(dependsOnMethods = "createUser")
    void addBookToUser() {
        String jsonString = String.format(
                "{\"userId\": \"%s\", \"collectionOfIsbns\": [{\"isbn\": \"9781593275846\"}]}", userId);

        RestAssured
                .given()
                    .baseUri(BASE_URL)
                    .accept(ContentType.JSON)
                    .contentType(ContentType.JSON)
                    .auth().preemptive().basic(username, "Password@123")
                    .body(jsonString)
                .when()
                    .post("BookStore/v1/Books")
                .then()
                .statusCode(201)
                .body("books[0].isbn", equalTo("9781593275846"));
    }

    @Test(dependsOnMethods = "addBookToUser")
    void getBooksForUser_expectOne() {
        RestAssured
                .given()
                    .baseUri(BASE_URL)
                    .accept(ContentType.JSON)
                    .contentType(ContentType.JSON)
                    .pathParam("userId", userId)
                    .auth().preemptive().basic(username, "Password@123")
                .when()
                    .get("Account/v1/User/{userId}")
                .then()
                .statusCode(200)
                .body("books.size()", equalTo(1));
    }


    @Test(dependsOnMethods = "getBooksForUser_expectOne")
    void deleteBooksForUser() {
        RestAssured
                .given()
                    .baseUri(BASE_URL)
                    .accept(ContentType.JSON)
                    .contentType(ContentType.JSON)
                    .queryParam("UserId", userId)
                    .auth().preemptive().basic(username, "Password@123")
                .when()
                    .delete("BookStore/v1/Books")
                .then()
                    .statusCode(204);
    }


    @Test(dependsOnMethods = "deleteBooksForUser")
    void getBooksForUser_expectZero() {
        RestAssured
                .given()
                    .baseUri(BASE_URL)
                    .accept(ContentType.JSON)
                    .contentType(ContentType.JSON)
                    .pathParam("userId", userId)
                    .auth().preemptive().basic(username, "Password@123")
                .when()
                    .get("Account/v1/User/{userId}")
                .then()
                    .statusCode(200)
                    .body("books.size()", equalTo(0));
    }


}
