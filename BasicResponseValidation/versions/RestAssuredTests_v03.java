package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.testng.Assert;
import org.testng.annotations.Test;

public class RestAssuredTests {

    private static final String URL = "https://httpbin.org/get";

    @Test
    void basicResponseTest() {
        Response response = RestAssured.get(URL);

        Assert.assertEquals(response.statusCode(), 200);
        Assert.assertEquals(response.statusLine(), "HTTP/1.1 200 OK");
        Assert.assertEquals(response.contentType(), "application/json");
    }
}
