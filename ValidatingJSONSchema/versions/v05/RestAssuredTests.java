package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.Test;

import static io.restassured.module.jsv.JsonSchemaValidator.matchesJsonSchemaInClasspath;

public class RestAssuredTests {

    private static final String TODOS_URL = "https://jsonplaceholder.typicode.com/todos";

    @Test
    public void testSchemaValidation() {
        RestAssured
                .get(TODOS_URL)
                .then()
                    .body(matchesJsonSchemaInClasspath("todos_schema.json"));
    }

}