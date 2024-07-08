package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.Test;

import static io.restassured.module.jsv.JsonSchemaValidator.matchesJsonSchemaInClasspath;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String TODOS_URL = "https://jsonplaceholder.typicode.com/todos/{id}";

    @Test
    public void testSchemaValidation() {
        RestAssured
                .given()
                    .pathParam("id", 5)
                .get(TODOS_URL)
                .then()
                    .body(matchesJsonSchemaInClasspath("todo_schema.json"));
    }

}