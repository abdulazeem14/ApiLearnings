package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.config.RedirectConfig;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredConfigurationTests {

    private static final String BASE_URL = "https://httpbin.org/redirect/{n}";



    @Test
    void testRedirect() {
        RestAssured
                .given()
                    .pathParam("n", 5)
                .when()
                    .get(BASE_URL)
                .then()
                    .statusCode(200);

    }

    @Test
    void testRedirect_withRedirectConfig() {
        RestAssured
                .given()
                    .config(RestAssured.config()
                            .redirect(new RedirectConfig()
                                    .followRedirects(true)
                                    .maxRedirects(6))
                    )
                    .pathParam("n", 5)
                .when()
                    .get(BASE_URL)
                .then()
                    .statusCode(200);

    }

}
