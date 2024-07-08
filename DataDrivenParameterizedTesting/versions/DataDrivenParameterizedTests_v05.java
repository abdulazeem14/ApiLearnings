package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.DataProvider;
import org.testng.annotations.Test;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
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
    public Iterator<Object[]> queryParamsCombinations() {
        return List.of (
                new Object[] {createMap("priority", 1, "completed", false), 6},
                new Object[] {createMap("priority", 2, "completed", true, "severity", "high"), 6},
                new Object[] {createMap("severity", "critical", "titleContains", "broken"), 1},
                new Object[] {createMap("severity", "medium", "completed", false, "createdByContains", "John"), 2}
        ).iterator();
    }

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
}
