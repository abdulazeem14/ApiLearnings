package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.config.ConnectionConfig;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

public class RestAssuredConfigurationTests {

    private static final String BASE_URL = "https://httpbin.org/get";

    @BeforeSuite
    void setup() {
        RestAssured.config = RestAssured.config()
                .connectionConfig(new ConnectionConfig().closeIdleConnectionsAfterEachResponse());
    }

    @Test
    void testConnection() {
        RestAssured
                .get(BASE_URL)
                .then()
                    .statusCode(200);
    }
}
