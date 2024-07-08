-----------------------------------------------
Data-driven tests using JSON and CSV files
-----------------------------------------------

-------------------------------------------------------
Use JSON file as string payload for POST request - v01
-------------------------------------------------------

# Behind the scenes rename the test file to 

DataDrivenTests.java

# Under src/test create a new package

resources

# Right-click -> Mark directory as -> Test Resources Root (it may already be marked as such, switch to another option and switch back)

# Under resources create another package

bugs

# Under bugs/ create a json file

bugs_01.json

{
  "createdBy": "Jack Farley",
  "priority": 3,
  "severity": "low",
  "title": "Page does not render correctly",
  "completed": false
}

# Create another json file

bugs_02.json

{
  "createdBy": "Susan Hill",
  "priority": 2,
  "severity": "high",
  "title": "Login functionality broken on mobile",
  "completed": false
}

# Create another json file

bugs_03.json

{
  "createdBy": "Mohamed Ali",
  "priority": 1,
  "severity": "medium",
  "title": "Email notifications delayed",
  "completed": false
}

# Under java/org/loonycorn/restassuredtests

# Create a package

utils

# Under utils/ create a file

FileUtil.java


import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Objects;

public class FileUtil {

    public static String readResourceFileAsString(String filePath)
            throws URISyntaxException, IOException {
        
        // Assuming filePath is relative to the src/test/resources directory
        String path = Objects.requireNonNull(
                FileUtil.class.getClassLoader().getResource(filePath)).toURI().getPath();

        return new String(Files.readAllBytes(Paths.get(path)));
    }
}


# Set up the DataDrivenTests.java file


import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.loonycorn.restassuredtests.utils.FileUtil;
import org.testng.annotations.Test;

import java.io.IOException;
import java.net.URISyntaxException;

public class DataDrivenTests {

    private final String BUGS_URL = "http://localhost:8080/bugs";

    @Test
    void testPOSTRequestToCreateBugOne() throws URISyntaxException, IOException {

        String bugBodyJson = FileUtil.readResourceFileAsString("bugs/bug_01.json");

        String bugId = RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(bugBodyJson)
                .when()
                    .post(BUGS_URL)
                .then()
                    .statusCode(201)
                    .extract().path("bugId");

        System.out.println("Bug ID: " + bugId);

        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .baseUri(BUGS_URL)
                    .pathParam("bug_id", bugId)
                .when()
                    .get("/{bug_id}")
                .then()
                    .statusCode(200);
    }
}


# Run the test and show that it passes

# Copy over the bug ID from the console at the bottom

# On the browser go to

http://localhost:8080/bugs/<bug_id>

# Show the bug exists



-------------------------------------------------------
Specify contents from JSON file using data provider - v02
-------------------------------------------------------

# Set up the code as below

public class DataDrivenTests {

    private final String BUGS_URL = "http://localhost:8080/bugs";

    @DataProvider(name = "bugPayloads")
    public Object[][] bugPayloads() throws URISyntaxException, IOException {
        return new Object[][] {
                {FileUtil.readResourceFileAsString("bugs/bug_01.json")},
                {FileUtil.readResourceFileAsString("bugs/bug_02.json")},
                {FileUtil.readResourceFileAsString("bugs/bug_03.json")}
        };
    }

    @Test(dataProvider = "bugPayloads")
    void testPOSTRequestToCreateBug(String bugBodyJson) {

        String bugId = RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(bugBodyJson)
                .when()
                    .post(BUGS_URL)
                .then()
                    .statusCode(201)
                    .extract().path("bugId");

        System.out.println("Bug ID: " + bugId);

        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .baseUri(BUGS_URL)
                    .pathParam("bug_id", bugId)
                .when()
                    .get("/{bug_id}")
                .then()
                    .statusCode(200);
    }
}


# Run the code and show this passes

# Now this works to a certain extent but you can't really check for anything, harder to debug when the payload is a string


-------------------------------------------------------
Specify contents from JSON file using data provider - v03
-------------------------------------------------------

# Update FileUtil.java to read JSON data as JSON object

# Add this code to FileUtil.java


    private static final ObjectMapper objectMapper = new ObjectMapper();



    public static  JsonNode readJsonFileAsJsonNode(String filePath)
            throws URISyntaxException, IOException {
        return objectMapper.readTree(readResourceFileAsString(filePath));
    }


# Update DataDrivenTests.java

# Note that we can now compare the response from the POST with the JSON data we passed into the POST

# We can also compare the response from the GET for an individual bug


import com.fasterxml.jackson.databind.JsonNode;
import io.restassured.RestAssured;
import org.testng.annotations.DataProvider;
import io.restassured.http.ContentType;
import org.loonycorn.restassuredtests.utils.FileUtil;
import org.testng.annotations.Test;

import java.io.IOException;
import java.net.URISyntaxException;

import static org.hamcrest.Matchers.*;

public class DataDrivenTests {

    private final String BUGS_URL = "http://localhost:8080/bugs";

    @DataProvider(name = "bugPayloads")
    public Object[][] bugPayloads() throws URISyntaxException, IOException {
        return new Object[][] {
                {FileUtil.readJsonFileAsJsonNode("bugs/bug_01.json")},
                {FileUtil.readJsonFileAsJsonNode("bugs/bug_02.json")},
                {FileUtil.readJsonFileAsJsonNode("bugs/bug_03.json")}
        };
    }

    @Test(dataProvider = "bugPayloads")
    void testPOSTRequestToCreateBug(JsonNode bugBodyJson) {

        String bugId = RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(bugBodyJson.toString())
                .when()
                    .post(BUGS_URL)
                .then()
                    .statusCode(201)
                    .body("bugId", notNullValue())
                    .body("createdBy", equalTo(bugBodyJson.get("createdBy").asText()))
                    .body("priority", equalTo(bugBodyJson.get("priority").asInt()))
                    .body("severity", equalTo(bugBodyJson.get("severity").asText()))
                    .body("title", equalToIgnoringCase(bugBodyJson.get("title").asText()))
                    .body("completed", equalTo(bugBodyJson.get("completed").asBoolean()))
                    .extract().path("bugId");

        System.out.println("Bug ID: " + bugId);

        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .baseUri(BUGS_URL)
                    .pathParam("bug_id", bugId)
                .when()
                    .get("/{bug_id}")
                .then()
                    .statusCode(200)
                    .body("bugId", equalTo(bugId))
                    .body("createdBy", equalTo(bugBodyJson.get("createdBy").asText()))
                    .body("priority", equalTo(bugBodyJson.get("priority").asInt()))
                    .body("severity", equalTo(bugBodyJson.get("severity").asText()))
                    .body("title", equalToIgnoringCase(bugBodyJson.get("title").asText()))
                    .body("completed", equalTo(bugBodyJson.get("completed").asBoolean()));
    }
}


-------------------------------------------------------
Specify contents from JSON file using data provider - v04
-------------------------------------------------------

# Under test/resources/bugs

# Add a file

all_bugs.json

# Set up a JSON array in that file

[
  {
    "createdBy": "Jack Farley",
    "priority": 3,
    "severity": "low",
    "title": "Page does not render correctly",
    "completed": false
  },
  {
    "createdBy": "Susan Hill",
    "priority": 2,
    "severity": "high",
    "title": "Login functionality broken on mobile",
    "completed": false
  },
  {
    "createdBy": "Mohamed Ali",
    "priority": 1,
    "severity": "medium",
    "title": "Email notifications delayed",
    "completed": false
  },
  {
    "createdBy": "Linda Kim",
    "priority": 2,
    "severity": "high",
    "title": "User login fails under heavy load",
    "completed": true
  }
]


# Under test/java/org/loonycorn/restassuredtests

# Create a new package

model

# Create a new file under that package

BugRequestBody.java

# Add file contents


import lombok.Data;

@Data
public class BugRequestBody {
    private String createdBy;
    private Integer priority;
    private String severity;
    private String title;
    private Boolean completed;
}


# In DataDrivenTests.java set up the following code


import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.restassured.RestAssured;
import org.loonycorn.restassuredtests.model.BugRequestBody;
import org.testng.annotations.DataProvider;
import io.restassured.http.ContentType;
import org.loonycorn.restassuredtests.utils.FileUtil;
import org.testng.annotations.Test;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import static org.hamcrest.Matchers.*;

public class DataDrivenTests {

    private final String BUGS_URL = "http://localhost:8080/bugs";
    private static final ObjectMapper objectMapper = new ObjectMapper();

    @DataProvider(name = "bugPayloads")
    public Iterator<BugRequestBody> bugPayloads() throws URISyntaxException, IOException {
        JsonNode jsonArray = FileUtil.readJsonFileAsJsonNode("bugs/all_bugs.json");

        List<BugRequestBody> bugList = new ArrayList<>();
        for (JsonNode element : jsonArray) {
            BugRequestBody bug = objectMapper.treeToValue(element, BugRequestBody.class);
            bugList.add(bug);
        }

        return bugList.iterator();
    }

    @Test(dataProvider = "bugPayloads")
    void testPOSTRequestToCreateBug(BugRequestBody bug) {

        String bugId = RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(bug)
                .when()
                    .post(BUGS_URL)
                .then()
                    .statusCode(201)
                    .body("bugId", notNullValue())
                    .body("createdOn", notNullValue())
                    .body("updatedOn", notNullValue())
                    .body("createdBy", equalTo(bug.getCreatedBy()))
                    .body("priority", equalTo(bug.getPriority()))
                    .body("severity", equalTo(bug.getSeverity()))
                    .body("title", equalTo(bug.getTitle()))
                    .body("completed", equalTo(bug.getCompleted()))
                    .extract().path("bugId");

        System.out.println("Bug ID: " + bugId);

        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .baseUri(BUGS_URL)
                    .pathParam("bug_id", bugId)
                .when()
                    .get("/{bug_id}")
                .then()
                    .statusCode(200)
                    .body("bugId", equalTo(bugId))
                    .body("createdOn", notNullValue())
                    .body("updatedOn", notNullValue())
                    .body("createdBy", equalTo(bug.getCreatedBy()))
                    .body("priority", equalTo(bug.getPriority()))
                    .body("severity", equalTo(bug.getSeverity()))
                    .body("title", equalTo(bug.getTitle()))
                    .body("completed", equalTo(bug.getCompleted()));
    }
}


# Run the tests and show


-------------------------------------------------------
Use a CSV file to set up a data-driven test - v05
-------------------------------------------------------


# Go to

https://mvnrepository.com/

# Search for 

apache commons csv

# Copy and paste the dependency in Maven 

<!-- https://mvnrepository.com/artifact/org.apache.commons/commons-csv -->
<dependency>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-csv</artifactId>
    <version>1.10.0</version>
</dependency>

# Reload the project


# Under resources/bugs create a csv file

bugs.csv

createdBy,priority,severity,title,completed
Amina Zahra,1,high,Login page fails,false
Carlos Mendez,2,medium,Profile page loads slowly,true
Yuki Takahashi,3,low,Search functionality missing,false
Fatima Al-Fihri,2,high,Email notifications delayed,true
Dmitri Ivanov,1,critical,Data export fails,false


# Add this to FileUtil.java

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;

import java.util.ArrayList;
import java.util.List;

import java.io.InputStreamReader;
import java.io.Reader;


    public static List<List<String>> readCSVFromResources(String filePath) {
        List<List<String>> records = new ArrayList<>();

        try (Reader reader = new InputStreamReader(Objects.requireNonNull(
                FileUtil.class.getClassLoader().getResourceAsStream(filePath)));

            CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT)) {

            for (CSVRecord csvRecord : csvParser) {
                List<String> record = new ArrayList<>();
                for (String field : csvRecord) {
                    record.add(field);
                }
                records.add(record);
            }

        } catch (IOException e) {
            e.printStackTrace();
        }

        return records;
    }


# Go to BugRequestBody.java and add this annotation


@Builder


# Change the data provider in DataDrivenTests.java



    @DataProvider(name = "bugPayloads")
    public Iterator<BugRequestBody> bugPayloads() {
        List<BugRequestBody> bugRequests = new ArrayList<>();
        List<List<String>> records = FileUtil.readCSVFromResources("bugs/bugs.csv");

        // Skip the header row
        for (int i = 1; i < records.size(); i++) {
            List<String> record = records.get(i);
            BugRequestBody bug = BugRequestBody.builder()
                    .createdBy(record.get(0))
                    .priority(Integer.valueOf(record.get(1)))
                    .severity(record.get(2))
                    .title(record.get(3))
                    .completed(Boolean.parseBoolean(record.get(4)))
                    .build();
            bugRequests.add(bug);
        }

        return bugRequests.iterator();
    }

# Run and show it passes

# Make a tweak to the asserts in teh test

# Run and show it fails
























































