package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.http.Headers;
import io.restassured.response.Response;
import org.testng.Assert;
import org.testng.annotations.Test;

public class RestAssuredTests {

    private static final String URL = "https://httpbin.org/get";

    @Test
    void basicResponseBodyTest() {
        Response response = RestAssured.get(URL);

        Headers headers = response.getHeaders();

        Assert.assertTrue(headers.hasHeaderWithName("Content-Type"));
        Assert.assertTrue(headers.hasHeaderWithName("Content-Length"));

        Assert.assertEquals(headers.get("Access-Control-Allow-Origin").getValue(), "*");
        Assert.assertEquals(headers.get("Server").getValue(), "gunicorn/19.9.0");
    }
}
