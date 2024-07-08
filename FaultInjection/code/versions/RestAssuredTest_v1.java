package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.testng.Assert;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

public class RestAssuredTests {

    private static final String BUGS_URL = "http://localhost:8090/bugs";
    int numRequests = 25;

    @DataProvider(name = "requests")
    public Object[][] requestsData() {
        Object[][] data = new Object[numRequests][1];
        for (int i = 0; i < numRequests; i++) {
            data[i][0] = i + 1;
        }
        return data;
    }

    @Test(dataProvider = "requests")
    public void loadTest(int requestNumber) {
        Response response = RestAssured.get(BUGS_URL);

        System.out.println("Request #" + requestNumber + ":");
        System.out.println("Status Code: " + response.statusCode());
        System.out.println("Response Body: " + response.body().asString());
        System.out.println("-----------------------------------");

        Assert.assertEquals(response.statusCode(), 200, "Status code is not 200");
    }
}