package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;
import static org.testng.Assert.assertEquals;

public class RestAssuredTests {

    private static final String BUGS_URL = "http://localhost:10000/bugs";
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
        long startTime = System.currentTimeMillis();
        Response response = RestAssured.get(BUGS_URL);
        long endTime = System.currentTimeMillis();

        long responseTime = endTime - startTime;

        System.out.println("Request #" + requestNumber + ":");
        System.out.println("Status Code: " + response.statusCode());
        System.out.println("Response Time (ms): " + responseTime);
        System.out.println("Response Body: " + response.body().asString());
        System.out.println("-----------------------------------");

        assertEquals(response.body().asString(), "[]");
    }
}