-----------------------------------------------
Set up the Bugs API Server
-----------------------------------------------


#############################
Creating the starter project
#############################

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

=> Open "src > main > java > com.loonycorn.bugsapi > BugsApiApplication.java"

=> We can delete the "test" folder

=> Click on the "Run" button near the class of BugsApiApplication and run the main() method
(Observe in the console tomcat is running in port 8080)

=> Expand "resource" folder observe we have "static" and "template" folder just like flask

=> Click on "application.properties"
(As some other application is running in port 8080 we will be changing the port to 8090)

=> Paste the below code in "application.properties"
server.port=8090


# Behind the scenes

# Add the contents of the two packages (including the code)

controller

model

# Show the code for

Bug.java

BugController.java


=> Click on the "Run" button near the class of BugsApiApplication and run the main() method
(Observe in the console tomcat is running in port 8090)


# Let's test the server

# On the browser

http://localhost:8090/

http://localhost:8090/bugs


# On the terminal

curl -X POST \
  http://localhost:8090/bugs \
  -H 'Content-Type: application/json' \
  -d '{
    "createdBy": "Kim Doe",
    "priority": 2,
    "severity": "Critical",
    "title": "Database Connection Failure",
    "completed": false
}' | jq

# Second bug

curl -X POST \
  http://localhost:8090/bugs \
  -H 'Content-Type: application/json' \
  -d '{
    "createdBy": "Jack Farley",
    "priority": 3,
    "title": "Page does not render correctly",
    "completed": false
}' | jq


# Retrieve bugs

curl -X GET http://localhost:8090/bugs | jq


# go to the browser and hit

http://localhost:8090/bugs

# Retrieve bug by ID

curl -X GET http://localhost:8090/bugs/<bug_id> | jq


# Try to retrieve a bug that does not exist

curl -X GET http://localhost:8090/bugs/<bug_id> | jq


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
  http://localhost:8090/bugs/6032eca7-e2aa-4894-8ab9-ca9bb005e254 \
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

curl -X DELETE http://localhost:8090/bugs/7e2a808f-c6d3-4771-8983-1e0d81ceee72


# Retrieve bugs

curl -X GET http://localhost:8090/bugs | jq

# There should just be one bug


# IMPORTANT: Stop the bug server running at the very end







































































