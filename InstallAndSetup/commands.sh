-----------------------------------------------
Install and set up
-----------------------------------------------

# On browser go to 

https://www.oracle.com/java/technologies/downloads/#java17

# Show that we can download Java for Linux, MacOS, and Windows

# Go to terminal - we have Java already installed

java --version


# Go to 

https://www.jetbrains.com/idea/download/

# Show that you can download IntelliJ for Linux, MacOS, and Windows

# Show that the Community Edition is free to use

------------

# Open up IntelliJ

New Project -> Maven Archetype -> learning-rest-assured

# Show JDK

# Change archetype to 

org.apache.maven.archetypes:maven-archetype-quickstart


# Open Advanced Settings

GroupId: org.loonycorn

# Create project

# Mave should build automatically

IntelliJ IDEA -> Preferences -> Editor -> Font

Change to 16

# Show pom.xml

# Add this under properties to compile with the right Java version

  <properties>
    <maven.compiler.target>17</maven.compiler.target>
    <maven.compiler.source>17</maven.compiler.source>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
  </properties>

# Right-click -> Maven -> Reload Project

# Expand 

src/main/java

src/test/java

# Show the default app set up

# Click on the App.java file

# Click on the Run icon and run the code and make sure everything works

# Click on AppTest.java

# Click on the Run icon and run the code and make sure everything works


--------------------

# Keep pom.xml open

# Expand External Libraries on the left and show what libraries we have


# Go to

https://mvnrepository.com/

# Search for

rest-assured

# Copy latest version

<!-- https://mvnrepository.com/artifact/io.rest-assured/rest-assured -->
<dependency>
    <groupId>io.rest-assured</groupId>
    <artifactId>rest-assured</artifactId>
    <version>5.4.0</version>
    <scope>test</scope>
</dependency>

# Paste in pom.xml

# Right-click -> Maven -> Reload Project

# Expand External Libraries on the left and show rest assured present

# Back to

https://mvnrepository.com/

# Search for

testng

# Copy to pom.xml 

# IMPORTANT: Replace JUnit

<!-- https://mvnrepository.com/artifact/org.testng/testng -->
<dependency>
    <groupId>org.testng</groupId>
    <artifactId>testng</artifactId>
    <version>7.9.0</version>
    <scope>test</scope>
</dependency>

# Right-click -> Maven -> Reload Project

# Expand External Libraries on the left and show testng present (no junit)

---------------

# Show AppTest.java - will have errors because no JUnit

# Delete AppTest.java

# Delete App.java

# Under test/java create a new package

restassuredtests

# Under this package create a new Java file

RestAssuredTests


# Add this code

public class RestAssuredTests {

    @Test
    void firstTest() {
        RestAssured
                .get("https://www.skillsoft.com")
                .then()
                .statusCode(200);
    }
}

# Hover over the red and add the imports

# Run the test it should pass

# Change 

200 -> 404

# Run the test, it should fail




































