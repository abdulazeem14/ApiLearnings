package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import static io.restassured.config.ParamConfig.UpdateStrategy.REPLACE;
import static io.restassured.config.ParamConfig.paramConfig;

public class RestAssuredConfigurationTests {

    private static final String BASE_URL = "https://httpbin.org/get";

    @BeforeSuite
    void setup() {
        RestAssured.config = RestAssured.config()
                .paramConfig(paramConfig().queryParamsUpdateStrategy(REPLACE));
    }

    @Test
    void testParameters() {
        RestAssured
                .given()
                    .queryParam("name", "Joe")
                    .queryParam("name", "Jess")
                    .queryParam("name", "Jack")
                    .log().uri()
                .get(BASE_URL)
                .then()
                    .statusCode(200);
    }
}
