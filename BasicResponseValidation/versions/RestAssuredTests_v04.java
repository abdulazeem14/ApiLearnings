package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.response.Response;
import io.restassured.response.ResponseBody;
import org.testng.Assert;
import org.testng.annotations.Test;

public class RestAssuredTests {

    private static final String URL = "https://httpbin.org/get";

    @Test
    void basicResponseBodyTest() {
        Response response = RestAssured.get(URL);

        ResponseBody responseBody = response.body();

        responseBody.peek();

        // "Host" header
        Assert.assertTrue(responseBody.asString().contains("httpbin.org"));

        // "Accept-Encoding" header
        Assert.assertTrue(responseBody.asString().contains("gzip,deflate"));
    }
}
