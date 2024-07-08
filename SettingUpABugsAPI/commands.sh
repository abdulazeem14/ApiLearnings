-----------------------------------------------------------
Set up the project for Rest Assured and the Bugs API Server
-----------------------------------------------------------

################################################
Set up the project behind the scenes and show the following here
Read through and structure the starter project this way
################################################


# Start on the terminal

java --version


# On the browser

https://mvnrepository.com/

# Search for 

rest-assured

testng

lombok

jackson-databind

# We'll start with these and add others later as needed

# Have the learning-rest-assured project set up behind the scenes

# pom.xml

Right-click -> Maven -> Reload

# Show the structure

# src/main/java should be empty only have org.loonycorn package

# src/test/java should be empty only have org.loonycorn.restassuredtests package


################################################
Creating the starter project for Bugs API Server
################################################

(For creating the Spring started project in Intellij, we require the "Ultimate" edition)
=> Goto "https://start.spring.io/"

=> Configure all the settings as shown in the screenshot

=> Click on "Generate" 

=> Extract the .zip file

=> Place this in the IDEAProjects folder on your machine

=> Open the folder in Intellij IDE

=> Click on File -> New -> Module from existing sources

=> Select the bugs-api project from IDEAProjects

=> Choose "Import module from external model"

=> Choose Maven

=> Import the project as a module

#############################

=> Open up "pom.xml"
(Observe we get an error 'org.springframework.boot:spring-boot-maven-plugin:' nversion not matching)

=> Add "<version>${project.parent.version}</version>" to the end of "spring-boot-maven-plugin" should look like the below 
# https://stackoverflow.com/questions/64639836/plugin-org-springframework-bootspring-boot-maven-plugin-not-found

```
<plugin>
	<groupId>org.springframework.boot</groupId>
	<artifactId>spring-boot-maven-plugin</artifactId>
	<version>${project.parent.version}</version>
</plugin>
```

# Show 

BugsApiApplication.java

# Behind the scenes

# Add the contents of the three packages (including the code)

controller

model

util

# Show the code for

Bug.java

BugUtil.java

BugController.java



=> Click on the "Run" button near the class of BugsApiApplication and run the main() method
(Observe in the console tomcat is running in port 8080)


# Let's test the server

# On the browser

http://localhost:8080/

http://localhost:8080/bugs


http://localhost:8080/bugs?priority=2

http://localhost:8080/bugs?severity=high

http://localhost:8080/bugs?completed=true

http://localhost:8080/bugs?createdByContains=John

http://localhost:8080/bugs?titleContains=responsive

http://localhost:8080/bugs?createdByContains=Sarah&priority=1

http://localhost:8080/bugs?priority=3&completed=true


# Retrieve bugs

curl -X GET http://localhost:8090/bugs | jq


# On the terminal

curl -X POST \
  http://localhost:8090/bugs \
  -H 'Content-Type: application/json' \
  -d '{
    "createdBy": "Jack Farley",
    "priority": 3,
    "title": "Page does not render correctly",
    "completed": false
}' | jq


# Go to the browser and hit

http://localhost:8090/bugs

# Retrieve bug by ID

curl -X GET http://localhost:8090/bugs/<bug_id>| jq



# Update the severity

curl -X PUT \
  http://localhost:8090/bugs/<bug_id> \
  -H 'Content-Type: application/json' \
  -d '{
    "createdBy": "Jack Farley",
    "priority": 3,
    "severity": "High",
    "title": "Page does not render correctly",
    "completed": false
}' | jq

# Retrieve bug by ID

curl -X GET http://localhost:8090/bugs/<bug_id> | jq


# Update the priority using PUT, will set everything to null except priority

curl -X PUT \
  http://localhost:8090/bugs/<bug_id> \
  -H 'Content-Type: application/json' \
  -d '{
    "priority": "2"
}' | jq

# Retrieve bug by ID

curl -X GET http://localhost:8090/bugs/<bug_id> | jq

# Use patch for partial updates

curl -X PATCH \
  http://localhost:8090/bugs/<bug_id> \
  -H 'Content-Type: application/json' \
  -d '{
    "priority": 1
}' | jq


# Delete a bug

curl -X DELETE http://localhost:8090/bugs/<bug_id>


# Retrieve bugs

curl -X GET http://localhost:8090/bugs | jq

# There should just be one bug


# IMPORTANT: Stop the bug server running at the very end







































































