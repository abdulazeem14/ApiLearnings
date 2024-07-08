package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.Test;

public class RestAssuredTests {

    @Test
    void firstTest() {
        RestAssured
                .get("https://www.skillsoft.com")
                .then()
                .statusCode(200);
    }
}
