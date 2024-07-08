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

        Assert.assertEquals(response.getHeader("Access-Control-Allow-Origin"), "*");
        Assert.assertEquals(response.getHeader("Server"), "gunicorn/19.9.0");
        Assert.assertEquals(Integer.parseInt(response.getHeader("Content-Length")), 323);
    }
}
