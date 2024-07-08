-----------------------------------------------
Specifying test environments
-----------------------------------------------


-----------------------------------------------
# We will first set up a testng.xml file


# The testng.xml file in TestNG (a testing framework for Java) is used for configuring and controlling a TestNG test suite. It allows you to define and group your test classes, methods, and parameters, enabling you to manage the execution of tests with greater flexibility and granularity. The testng.xml file provides a way to specify which tests to run, set test parameters, include or exclude groups of tests, define test dependencies, and more, without needing to alter your test code.


# We can easily create a file by installing a plugin

# Goto Intellij IDEA preferences 
# Search for plugins.
# Click on Marketplace.
# Search for testng.
# Install the plugin "Create TestNG XML" and Apply the changes.
# Restart Intellij.
# Right on your project and click on "Create TestNG XML"
# Click OK on the confirmation dialog.

# File created

# Right-click on your project -> Reload from disk

# You can see the file

testng.xml

# Show the contents

# Go to Code -> Reformat code and then show

# It may not have all tests - update it

# Should look like this below

<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE suite SYSTEM "http://testng.org/testng-1.0.dtd">
<suite name="All Test Suite">
    <test verbose="2" preserve-order="true" name="/Users/apple/IdeaProjects/learning-rest-assured">
        <classes>
            <class name="org.loonycorn.restassuredtests.BugsAPICRUDTests">
                <methods>
                    <include name="testPOSTCreateBugOne"/>
                    <include name="testPOSTCreateBugTwo"/>
                    <include name="testGETTwoMoreBugsPresent"/>
                    <include name="testPOSTUpdateBug"/>
                </methods>
            </class>
        </classes>
    </test>
</suite>


# Right-click on testng.xml -> Run testng.xml - this will run the tests using the file

# Remove one test from the file and run again - it will run fewer tests

# Add the test back to the file

-----------------------------------------------
# Next we need to set up the Maven Surefire plugin to be able to execute unit tests using the maven test command

# The Maven Surefire Plugin is a powerful tool used in Apache Maven projects to execute unit tests. It's one of the core plugins of Maven and is specifically designed to run tests written with frameworks like JUnit, TestNG, and others during the test phase of the Maven lifecycle. When you run mvn test, Maven Surefire is the plugin that gets invoked to carry out the test execution.

# Test Execution: Automatically detects and executes all tests in the src/test/java directory. It supports various testing frameworks, including JUnit (versions 3.x and 4.x are supported out of the box, and JUnit 5 with additional configuration), TestNG, and others.


# Go to

https://maven.apache.org/surefire/maven-surefire-plugin/

# Select TestNG from the links close to the middle of the page

# On this page go to Using Suite XML Files - copy the plugin over

# Open pom.xml and paste this in there

# Please note that the plugin is within build -> plugins

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>3.2.5</version>
        <configuration>
          <suiteXmlFiles>
            <suiteXmlFile>testng.xml</suiteXmlFile>
          </suiteXmlFiles>
        </configuration>
      </plugin>
    </plugins>
  </build>

# Reload the project

-----------------------------------------------

# Now let's run our suite of tests using Maven and the Surefire plugin

# On the top right click on Edit Configuration

# From the dialog on the left - choose Maven

# Name the configuration

bugs-api-tests-runner

# Under run specify the command used to run Maven tests

test 

# Working directory should be learning-rest-assured

# Apply and Close

# Now run this configuration

# Our tests should run and pass!


-----------------------------------------------
# We may want to run the same set of tests in different environments
# dev, qa, test

# Each environment will have different settings (authentication, and other settings) and different endpoints
# How can we manage this seamlessly?

# Let's set up a json file containing all the settings for the different environments

# Under resources/ create two packages

dev
qa

# In each package create a JSON file

bug_test_settings.json

# Under dev specify this

{
  "endpoint": "http://localhost:8080"
}

# Under qa specify this

{
  "endpoint": "http://localhost:9090"
}


-----------------------------------------------
# We'll now use a utility to read this file based on the environment set
# We'll use composition not inheritance here

# Under restassuredtests/ create

util

# under util/ create 

JsonUtils.java

# Add this code

package org.loonycorn.restassuredtests.util;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.Objects;

public class JsonUtils {
    private static final ObjectMapper objectMapper = new ObjectMapper();

    public static String readResourceFileAsString(String filePath)
            throws URISyntaxException, IOException {
        // Assuming filePath is relative to the src/test/resources directory
        String path = Objects.requireNonNull(
                JsonUtils.class.getClassLoader().getResource(filePath)).toURI().getPath();

        return new String(Files.readAllBytes(Paths.get(path)));
    }

    public static JsonNode readJsonFileAsJsonNode(String filePath)
            throws URISyntaxException, IOException {
        return objectMapper.readTree(readResourceFileAsString(filePath));
    }

}


# Now chnage this in BaseBugAPITests


    @BeforeSuite
    void setup() {
        String env = "dev";
        String endpoint = "";

        try {
            String filePath = String.format("%s/bug_test_settings.json", env);

            JsonNode json = JsonUtils.readJsonFileAsJsonNode(filePath);
            endpoint = json.get("endpoint").asText();
        } catch (URISyntaxException | IOException e) {
            throw new RuntimeException(e);
        }

        RestAssured.baseURI = endpoint;
        RestAssured.basePath = "bugs";

        System.out.println("Endpoint used: " + endpoint);

        RestAssured.requestSpecification = new RequestSpecBuilder()
                .setContentType(ContentType.JSON)
                .build();
    }


# Run the suite using the Maven running - the tests should pass

# Look in the console and see the URL being hit (should be the dev URL)

# Change the environment to "qa"

# Run the suite using the Maven running - the tests should fail

# Look in the console and see the URL being hit (should be qa url)


-----------------------------------------------
# Now let's pass the environment variable from the command line while running tests

# Click on "Edit" for the bugs-api-test-runner (using the 3 dots)

# Change the Maven command to pass in an env

test -Denv=dev


# Now change the code in setup() to read this

        String env = System.getProperty("env") == null ?  "dev" : System.getProperty("env");


# Run the suite using the Maven running - the tests should pass

# Look in the console and see the URL being hit (should be the dev URL)


# Click on "Edit" for the bugs-api-test-runner (using the 3 dots)

# Change the Maven command to pass in an env

test -Denv=qa

# Run the suite using the Maven running - the tests should fail

# Look in the console and see the URL being hit (should be qa url)


-----------------------------------------------

# Now stop the BugsApiApplication running

# Under resources/application.properties

# Add this to the file

server.port=9090

# Restart the server

# Re-run the bugs-api-test-runner

# Now the tests should pass

# Look in the console and see the URL being hit (should be qa url)


























































