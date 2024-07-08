-----------------------------------------------
RestAssured configuration
-----------------------------------------------

# Remove the model and other folders - not needed for this test


-----------------------------------
# Show the configurations that RestAssured supports

# Start with our RestAssuredConfigurationTests.java class like this

package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredConfigurationTests {
}


# Select RestAssured from the import and go to the RestAssured class Cmd + B

# On line 69 you can see the RestAssuredConfig

# Cmd + B on this config and show all the options

# Cmd + B on the following config and show

RedirectConfig (show the default value for redirect is true and 100 times)

HttpClientConfig

JsonConfig

ParamConfig

FailureConfig

----------------------------------

# Now go to 

https://httpbin.org/

# Go to the redirects section

# Expand this section

GET redirect/{n}

# Specify a value of n = 2 and show the response

# Right-click -> Inspect -> Go to network

# Clear everything

# Make another request and show how there are multiple requests made behind the scenes by the browser client

# IMPORTANT: Change the value of n = 4 and show many more redirects



----------------------------------
# Redirect config per request - v01
----------------------------------


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
}


# Run and show it passes


------------

# Now set the config for this request to not follow redirects



    @Test
    void testRedirect_withRedirectConfig() {
        RestAssured
                .given()
                    .config(RestAssured.config()
                            .redirect(new RedirectConfig()
                            	.followRedirects(false))
                    )
                    .pathParam("n", 5)
                .when()
                    .get(BASE_URL)
                .then()
                    .statusCode(200);

    }

# Run and show this fails (status code mismatch)

# Change the configuration

.followRedirects(true).maxRedirects(0)

# Run and show this fails (max redirects exceeded)

.followRedirects(true).maxRedirects(3)

# Run and show this fails again (max redirects exceeded again)

.followRedirects(true).maxRedirects(6)

# Run and show this passes (because we have set redirects to 5)


----------------------------------
# Redirect config for all requests - v02
----------------------------------

# Now move the config to apply to all tests


public class RestAssuredConfigurationTests {

    private static final String BASE_URL = "https://httpbin.org/redirect/{n}";

    @BeforeSuite
    void setup() {
        RestAssured.config = RestAssured.config()
                .redirect(new RedirectConfig()
                        .followRedirects(true)
                        .maxRedirects(6));
    }


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
}


# Run the suite and show that the tests pass


# Now add another bit of config

.followRedirects(true).maxRedirects(6).rejectRelativeRedirect(true)

# run and show this fails (this was a relative redirect that failed)

# Remove the last bit of configuration and make sure the test passes


----------------------------------
# Connection config for all requests - v03
----------------------------------

# Lets you configure connection settings for REST Assured. For example if you want to force-close the Apache HTTP Client connection after each response. You may want to do this if you make a lot of fast consecutive requests with small amount of data in the response. However if you're downloading (especially large amounts of) chunked data you must not close connections after each response. By default connections are not closed after each response.


# Nothing in the test here, just to show you how the config works


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

# Run the test and show that it passes


----------------------------------
# HTTPClient config for all requests - v04
----------------------------------

# Let's you configure properties for the HTTP Client instance that REST Assured will be using when executing requests. By default REST Assured creates a new instance of http client for each "given" statement. To configure reuse do the following

# You can also supply a custom HTTP Client instance by using the httpClientFactory method, for example:

# Again nothing that we can really see in the test


import io.restassured.RestAssured;
import io.restassured.config.HttpClientConfig;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

public class RestAssuredConfigurationTests {

    private static final String BASE_URL = "https://httpbin.org/get";

    @BeforeSuite
    void setup() {
        RestAssured.config = RestAssured.config()
                .httpClient(new HttpClientConfig().reuseHttpClientInstance());
    }

    @Test
    void testConnection() {
        RestAssured
                .get(BASE_URL)
                .then()
                    .statusCode(200);
    }
}


# Run the test and show that it passes


----------------------------------
# PAram config for all requests - v05
----------------------------------

# ParamConfig allows you to configure how different parameter types should be updated on "collision". By default all parameters are merged so if you do:

# REST Assured will send a query string of param1=value1&param1=value2. This is not always what you want though so you can configure REST Assured to replace values instead:


import io.restassured.RestAssured;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.Test;

public class RestAssuredConfigurationTests {

    private static final String BASE_URL = "https://httpbin.org/get";

    @BeforeSuite
    void setup() {
    }

    @Test
    void testParameters() {
        RestAssured
                .given()
                    .queryParam("name", "Joe")
                    .queryParam("name", "Jess")
                    .queryParam("name", "Jack")
                    .log().uri()
                .get(BASE_URL)
                .then()
                    .statusCode(200);
    }
}


# Run this test and show the URL that we actually hit in the console log


# Now change the way we deal with parameter merging

# Note that there are static methods to create each type of config

    @BeforeSuite
    void setup() {
        RestAssured.config = RestAssured.config()
                .paramConfig(paramConfig().queryParamsUpdateStrategy(REPLACE));
    }


# Run and show how the last parameter is accepted, parameters are NOT merged


----------------------------------
# Failure config for all requests - v06
----------------------------------

# First set things up with no failure listener


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
    }

    @Test
    void testParameters() {
        RestAssured
                .get(BASE_URL)
                .then()
                    .statusCode(404);
    }
}


# Run the test, it will fail (status mismatch), we will get no additional details


# Now in setup() set up a failure listener

        ResponseValidationFailureListener printDetails =
                (RequestSpecification reqSpec, ResponseSpecification respSpec, Response resp) -> {

            System.out.println("\nResponse Details:");
            System.out.println("Status Code: " + resp.getStatusCode());
            System.out.println("Headers: " + resp.getHeaders());
            System.out.println("Body:\n" + resp.getBody().asString());
        };

        RestAssured.config = RestAssured.config()
                .failureConfig(failureConfig().failureListeners(printDetails));




# Run the test, it will fail (status mismatch), bug we get a lot of additional details

# Change status to 200 to make the test pass - when the test passes we get no additional information





































