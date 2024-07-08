################################
Setting up Allure Reports
################################

=> Go to

https://allurereport.org/

=> Scroll and show on this page

=> Click on "Get Started" on the top right

=> Show all the different ways you can install allure

=> Scroll down to the section at the bottom "Install from an archive"

=> Click on the link to go to github to download the archive
# Will go to this page "https://github.com/allure-framework/allure2/releases/tag/2.27.0"

=> Download "allure-2.27.0.zip"

########################################

# In terminal
$ java --version

$ cd ~/Downloads/

$ unzip allure-2.27.0.zip

$ sudo mv allure-2.27.0 ~/

$ cd ~/allure-2.27.0/bin/

$ ls -l

$ pwd

$ nano ~/.zshrc

# Add the below line at the end of the file
export PATH="/Users/loonycorn/allure-2.27.0/bin:$PATH"

$ source ~/.zshrc

$ allure --version

########################################


# => Open pom.xml and add the following

# => In the <properties> section (the section should already be there)
# The version 2.27.0 was not available in the Maven repo at the time of this recording

<properties>
    <allure.version>2.25.0</allure.version>
</properties>


# => In the <dependencyManagement> section (will have to create new)

<!-- Add allure-bom to dependency management to ensure correct versions of all the dependencies are used -->
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>io.qameta.allure</groupId>
            <artifactId>allure-bom</artifactId>
            <version>${allure.version}</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>


# => In the <dependencies> section

    <!-- https://mvnrepository.com/artifact/io.qameta.allure/allure-testng -->
    <dependency>
        <groupId>io.qameta.allure</groupId>
        <artifactId>allure-testng</artifactId>
        <scope>test</scope>
    </dependency>>


# => Add aspectj to the <properties> section (section is already defined)

  <properties>
    <aspectj.version>1.9.20.1</aspectj.version>
  </properties>

# => Update the Maven SureFire plugin to look like this

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>3.2.5</version>
        <configuration>
          <argLine>
              -javaagent:"${settings.localRepository}/org/aspectj/aspectjweaver/${aspectj.version}/aspectjweaver-${aspectj.version}.jar"
          </argLine>
          <suiteXmlFiles>
            <suiteXmlFile>testng.xml</suiteXmlFile>
          </suiteXmlFiles>
        </configuration>
      </plugin>
    </plugins>
  </build>


=> Add aspectj to the <dependencies> section

    <dependency>
        <groupId>org.aspectj</groupId>
        <artifactId>aspectjweaver</artifactId>
        <version>${aspectj.version}</version>
    </dependency>  



# => Refresh the project

########################################


=> Open "BugsApiTest.java" and run the test

=> Everything should pass

=> Observe we get a new folder called "allure-results"

=> Open the "allure-results" folder and show all the files
(Click Command + alt + Shift + L to format the code)


# In terminal

$ cd /Users/loonycorn/IdeaProjects/learning-allure-reports

$ allure serve

=> Open the browser and goto the URL in the console output

=> Show the Allure Report and click on all the tabs (links on the left)


########################################

# If we want to run the test and generate the report from the terminal we can follow the below command

=> Open "BugsApiTest.java" 

=> Cause one of the tests to fail (compare size() to 3)

    public void testGETRetrieveBugs() {
        RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .body("size()", equalTo(3));
    }


$ mvn clean test 

=> We should have some passed, failed, and skipped tests

$ allure serve



=> Show the Allure Report and click on all the tabs (links on the left)

=> Under "Suites"

=> Show that we can see all the different statuses of tests

=> Hover on the numbers in color at the top to show the filtering

=> Click on the numbers in color at the top to show the filtering

=> Select the individual tests and show the test details (Overview, History, Retries)


















