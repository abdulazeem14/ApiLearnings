-----------------------------------------------
Data-driven parameterized tests
-----------------------------------------------

# IMPORTANT: Restart the BugApplicationApi server


# Right-click on src/test/java/org.loonycorn/restassuredtests

# Create a new file

DataDrivenParameterizedTests.java


-----------------------------------------------
Simple test - v01
-----------------------------------------------

# Add this simple test


package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.equalTo;

public class DataDrivenParameterizedTests {

    private final String BUGS_URL = "http://localhost:8080/bugs";

    @Test
    void testGETRequest() {
        RestAssured
                .get(BUGS_URL)
                .then()
                .statusCode(200)
                .body("size()", equalTo(25));
    }

}

# Run and show that this passes


-----------------------------------------------
# Testing using different request params 

# Add this test


    @Test
    void testGETRequestCreatedByContains() {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("createdByContains", "Jane")
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("createdBy", everyItem(containsString("Jane")));
    }


# Run and show

# Now add tests for all single parameters

    @Test
    void testGETRequestByPriority() {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("priority", 2)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("priority", everyItem(equalTo(2)));
    }

    @Test
    void testGETRequestBySeverity() {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("severity", "high")
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("severity", everyItem(equalTo("high")));
    }

    @Test
    void testGETRequestByCompletedStatus() {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("completed", true)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("completed", everyItem(is(true)));
    }

    @Test
    void testGETRequestTitleContains() {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("titleContains", "error")
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("title", everyItem(containsString("error")));
    }


# But you may want to test multiple values for these parameters

# Add this to testGETRequestCreatedByContains (do a copy paste from the already existing test and change values)

        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("createdByContains", "Williams")
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("createdBy", everyItem(containsString("Williams")));


# Run and show

# Add this to testGETRequestByPriority (do a copy paste from the already existing test and change values)

        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("priority", 0)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("priority", everyItem(equalTo(0)));

# Run and show

# Add this to testGETRequestBySeverity (do a copy paste from the already existing test and change values)


        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("severity", "critical")
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("severity", everyItem(equalTo("critical")));

# Run and show

# Quite painful let's stop here

# But we haven't considered multiple parameters!

-----------------------------------------------
# Testing using multiple request params (combos can get even more painful)

# Add this at the end


    @Test
    void testGETRequestMultipleFilters() {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("severity", "medium")
                    .queryParam("completed", false)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("severity", everyItem(equalTo("medium")))
                    .body("completed", everyItem(is(false)));
    }


# Run only this test and show



-----------------------------------------------
Data-driven parameterized test - v02
-----------------------------------------------

# Start with empty class

public class DataDrivenParameterizedTests {

    private final String BUGS_URL = "http://localhost:8080/bugs";

}


# Add the method to provide data - has to return Object[][] or Iterator<Object>


    public Object[][] createdByQueryParams() {
        return new Object[][] {
                {"Jane"}, {"Williams"}, {"Brown"}, {"Mike"}
        };
    }


# Add this annotation

    @DataProvider

# So we now have     


    @DataProvider
    public Object[][] createdByQueryParams() {
        return new Object[][] {
                {"Jane"}, {"Williams"}, {"Brown"}, {"Mike"}
        };
    }

# Now add the test that will use the data provided

    void testGETRequestCreatedByContains(String createdByContains) {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("createdByContains", createdByContains)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("createdBy", everyItem(containsString(createdByContains)));
    }


# Add this annotation to the test


    @Test(dataProvider = "createdByQueryParams")

# Now run and show

# Test will run 4 times, one for each data value


-----------------------

# Remove the dataProvider from the test annotation so it is

@Test


# Run the test you should get a dependency injection error

# Add the dataProvider back


    @Test(dataProvider = "createdByQueryParams")


# Remove the annotation on the createdByQueryParams

    @DataProvider

# Run the test should get an error saying a @DataProvider is needed


-------------------------
# Now can test all values of each query param
# Priority

    @DataProvider(name = "priorityQueryParams")
    public Object[][] priorityQueryParams() {
        return new Object[][] {
                {0}, {1}, {2}, {3}
        };
    }

    @Test(dataProvider = "priorityQueryParams")
    void testGETRequestByPriority(Integer priority) {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("priority", priority)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("priority", everyItem(equalTo(priority)));
    }


# Run this and show

-------------------------
# Now can test all values of each query param
# Severity



    @DataProvider(name = "severityQueryParams")
    public Object[][] severityQueryParams() {
        return new Object[][] {
                {"low"}, {"medium"}, {"high"}, {"critical"}
        };
    }

    @Test(dataProvider = "severityQueryParams")
    void testGETRequestBySeverity(String severity) {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("severity", severity)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("severity", everyItem(equalTo(severity)));
    }

# Run this and show

-------------------------
# Now can test all values of each query param
# completed

	@DataProvider(name = "completedQueryParams")
	public Object[][] completedQueryParams() {
	    return new Object[][] {
	        {true}, {false}
	    };
	}

	@Test(dataProvider = "completedQueryParams")
	void testGETRequestByCompleted(Boolean completed) {
	    RestAssured
	            .given()
	                .baseUri(BUGS_URL)
	                .queryParam("completed", completed)
	            .when()
	                .get()
	            .then()
	                .statusCode(200)
	                .body("completed", everyItem(is(completed)));
	}

# Run this and show

-------------------------
# Now can test all values of each query param
# titleContains

	@DataProvider(name = "titleContainsQueryParams")
	public Object[][] titleContainsQueryParams() {
	    return new Object[][] {
	        {"error"}, {"fail"}, {"timeout"}, {"incorrect"}
	    };
	}

	@Test(dataProvider = "titleContainsQueryParams")
	void testGETRequestTitleContains(String titleContains) {
	    RestAssured
	            .given()
	                .baseUri(BUGS_URL)
	                .queryParam("titleContains", titleContains)
	            .when()
	                .get()
	            .then()
	                .statusCode(200)
	                .body("title", everyItem(containsString(titleContains)));
	}


# Run this and show



-----------------------------------------------
Data-driven multiple parameterized test - v03
-----------------------------------------------

# Remove all the previous tests and add this



public class DataDrivenParameterizedTests {

    private final String BUGS_URL = "http://localhost:8080/bugs";

    @DataProvider(name = "severityAndTitleContainsQueryParams")
    public Object[][] severityAndTitleContainsQueryParams() {
        return new Object[][] {
                {"low", "error"},
                {"low", "broken"},
                {"medium", "fail"},
                {"high", "timeout"},
                {"critical", "incorrect"}
        };
    }

    @Test(dataProvider = "severityAndTitleContainsQueryParams")
    void testGETRequestBySeverityAndTitleContains(String severity, String titleContains) {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("severity", severity)
                    .queryParam("titleContains", titleContains)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("severity", everyItem(equalTo(severity)))
                    .body("title", everyItem(containsString(titleContains)));
    }
}


# Run and show

# Make a tweak to the test

titleContains + "sasd"

# Run the test and show the tests fail

# If a test passes that is because that query returns nothing

# Get the test to pass again

-------------------------
# One more combination



    @DataProvider(name = "priorityAndCompletedQueryParams")
    public Object[][] priorityAndCompletedQueryParams() {
        return new Object[][] {
                {0, true},
                {1, false},
                {2, true},
                {3, false}
        };
    }

    @Test(dataProvider = "priorityAndCompletedQueryParams")
    void testGETRequestByPriorityAndCompleted(Integer priority, Boolean completed) {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParam("priority", priority)
                    .queryParam("completed", completed)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("priority", everyItem(equalTo(priority)))
                    .body("completed", everyItem(is(completed)));
    }



# Run this test and show


-----------------------------------------------
Any number of parameters using map - v04
-----------------------------------------------

# First let's peek at the responses to see them


import io.restassured.RestAssured;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import java.util.HashMap;
import java.util.Map;

import static org.hamcrest.Matchers.*;

public class DataDrivenParameterizedTests {

    private final String BUGS_URL = "http://localhost:8080/bugs";

    private Map<String, Object> createMap(Object... data) {
        Map<String, Object> map = new HashMap<>();
        for (int i = 0; i < data.length; i += 2) {
            map.put((String) data[i], data[i + 1]);
        }
        return map;
    }

    @DataProvider(name = "queryParamsCombinations")
    public Object[][] queryParamsCombinations() {
        return new Object[][] {
                {createMap("priority", 1, "completed", false)},
                {createMap("priority", 2, "completed", true, "severity", "high")},
                {createMap("severity", "critical", "titleContains", "broken")},
                {createMap("severity", "medium", "completed", false, "createdByContains", "John")}
        };
    }

    @Test(dataProvider = "queryParamsCombinations")
    void testGETRequestWithQueryParamsMap(Map<String, Object> queryParams) {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParams(queryParams)
                .when()
                    .get()
                    .peek();
    }
}

# Run the test

# In the response window search for "bugId" - there should be 15 (just keep this in mind for later)

---------------------------------------
# Change the test to check the status code

        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParams(queryParams)
                .when()
                    .get()
                .then()
                    .statusCode(200);

# Run and show that it passes

# But how do I test the results?


---------------------------------------

# The number of bugs returned in the responses are

6, 6, 1, 2

# Change the function to also specify the expected size of response for each map


    @DataProvider(name = "queryParamsCombinations")
    public Object[][] queryParamsCombinations() {
        return new Object[][] {
                {createMap("priority", 1, "completed", false), 6},
                {createMap("priority", 2, "completed", true, "severity", "high"), 6},
                {createMap("severity", "critical", "titleContains", "broken"), 1},
                {createMap("severity", "medium", "completed", false, "createdByContains", "John"), 2}
        };
    }


# Change the test


    @Test(dataProvider = "queryParamsCombinations")
    void testGETRequestWithQueryParamsMap(Map<String, Object> queryParams, int expectedCount) {
        RestAssured
                .given()
                    .baseUri(BUGS_URL)
                    .queryParams(queryParams)
                .when()
                    .get()
                .then()
                    .statusCode(200)
                    .body("size()", equalTo(expectedCount));
    }

# Run and show it passes


-----------------------------------------------
Return an iterator instead of a nested object - v05
-----------------------------------------------

# Change the data provider method


    @DataProvider(name = "queryParamsCombinations")
    public Iterator<Object[]> queryParamsCombinations() {
        return List.of (
                new Object[] {createMap("priority", 1, "completed", false), 6},
                new Object[] {createMap("priority", 2, "completed", true, "severity", "high"), 6},
                new Object[] {createMap("severity", "critical", "titleContains", "broken"), 1},
                new Object[] {createMap("severity", "medium", "completed", false, "createdByContains", "John"), 2}
        ).iterator();
    }


 # No change to the test
 
 # Run the test and show

    






















