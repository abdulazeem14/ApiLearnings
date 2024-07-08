package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.listener.ResponseValidationFailureListener;
import io.restassured.response.Response;
import io.restassured.specification.RequestSpecification;
import io.restassured.specification.ResponseSpecification;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import static io.restassured.config.FailureConfig.failureConfig;

public class RestAssuredConfigurationTests {

    private static final String BASE_URL = "https://httpbin.org/get";

    @BeforeSuite
    void setup() {
        ResponseValidationFailureListener printDetails =
                (RequestSpecification reqSpec, ResponseSpecification respSpec, Response resp) -> {

            System.out.println("\nResponse Details:");
            System.out.println("Status Code: " + resp.getStatusCode());
            System.out.println("Headers: " + resp.getHeaders());
            System.out.println("Body:\n" + resp.getBody().asString());
        };

        RestAssured.config = RestAssured.config()
                .failureConfig(failureConfig().failureListeners(printDetails));
    }

    @Test
    void testParameters() {
        RestAssured
                .get(BASE_URL)
                .then()
                    .statusCode(200);
    }
}
