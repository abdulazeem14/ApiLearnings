package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.builder.RequestSpecBuilder;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import org.testng.annotations.DataProvider;

import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.equalTo;

public class FaultInjectionTests {

    int NUM_REQUESTS = 20;

    @BeforeSuite
    void setup() {
        RestAssured.baseURI = "http://localhost:10000";
        RestAssured.basePath = "products/1";

        RestAssured.requestSpecification = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .setAccept(ContentType.JSON)
                .build();
    }

    @DataProvider(name = "requests")
    public Object[][] requestsData() {
        Object[][] data = new Object[NUM_REQUESTS][1];
        for (int i = 0; i < NUM_REQUESTS; i++) {
            data[i][0] = i + 1;
        }

        return data;
    }

    @Test(dataProvider = "requests")
    public void loadTest(int requestNumber) {
        Response response = RestAssured.get();

        System.out.println("Request #: " + requestNumber);
        System.out.println("Status Code: " + response.statusCode());
        System.out.println("Response Body: " + response.body().asString());
        System.out.println("-----------------------------------");

        assertThat(response.statusCode(), equalTo(200));
    }

}