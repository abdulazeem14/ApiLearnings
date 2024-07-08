-----------------------------------------------
Validating JSON schema
-----------------------------------------------

# Go to 

https://jsonplaceholder.typicode.com/todos/1

# Show the schema

# Change to 3, 5, 10

# Show the basic structure is the same

# Go to

https://mvnrepository.com/

# Search for

json schema validator

# Choose the JSON schema validator for Rest Assured (released in December)

# Click through and choose the latest version

<!-- https://mvnrepository.com/artifact/io.rest-assured/json-schema-validator -->
<dependency>
    <groupId>io.rest-assured</groupId>
    <artifactId>json-schema-validator</artifactId>
    <version>5.4.0</version>
</dependency>


# Add to pom.xml just below the Rest Assured dependency

# Show that they have the same version

# Add a new property under the <properties> tab

<restassured.version>5.4.0</restassured.version>

# Now update the versions of both rest assured dependencies

    <!-- https://mvnrepository.com/artifact/io.rest-assured/rest-assured -->
    <dependency>
      <groupId>io.rest-assured</groupId>
      <artifactId>rest-assured</artifactId>
      <version>${restassured.version}</version>
      <scope>test</scope>
    </dependency>

    <!-- https://mvnrepository.com/artifact/io.rest-assured/json-schema-validator -->
    <dependency>
      <groupId>io.rest-assured</groupId>
      <artifactId>json-schema-validator</artifactId>
      <version>${restassured.version}</version>
    </dependency>

# Right-click -> Reload project


-------------------------------------

# Now let's create a json schema 

# Go to

https://jsonplaceholder.typicode.com/todos/1

# Copy over the json

# Go to the browser (www.google.com) and search

json schema generator

# Should see many different listings

# Select liquid technologies 

# Paste in the JSON and get the schema

{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "object",
  "properties": {
    "userId": {
      "type": "integer"
    },
    "id": {
      "type": "integer"
    },
    "title": {
      "type": "string"
    },
    "completed": {
      "type": "boolean"
    }
  },
  "required": [
    "userId",
    "id",
    "title",
    "completed"
  ]
}

# Now head over to the IntelliJ project

# Under the package

java/test

# Create a new package

resources

# This should have the symbol showing it is a "Resources Root"

# Right-click on the package "Mark Directory as" -> "Test Resources Root"

# Create a new file in that package 

todo_schema.json

-----------------------------------------------
# Now go to RestAssuredTests.Java (v01)

package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.Test;

import static io.restassured.module.jsv.JsonSchemaValidator.matchesJsonSchemaInClasspath;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String TODOS_URL = "https://jsonplaceholder.typicode.com/todos/{id}";

    @Test
    public void testSchemaValidation() {
        RestAssured
                .given()
                    .pathParam("id", 1)
                .get(TODOS_URL)
                .then()
                    .body(matchesJsonSchemaInClasspath("todo_schema.json"));
    }

}

# Run the tests, it should pass

# Now we've done validation but we haven't understood how it is validating the schema


-----------------------------------------------

# Now go to todo_schema.json

# Get rid of everything here, so you are left with

{
}

# Run the test and show that it passes

# This is because we are not testing anything here
# This schema constrains nothing, validates nothing

# Now change the schema to have only the $schema entry

{
  "$schema": "http://json-schema.org/draft-04/schema#"
}

----------
# Notes

# JSON Schema is defined by several drafts, each representing a different version of the specification. As of my last update in January 2022, the major JSON Schema drafts are:

# JSON Schema Draft 4: This was the first major version of JSON Schema. It was published in 2013 and is defined by the JSON Schema Working Group. It provides basic validation capabilities for JSON documents.

# JSON Schema Draft 6: This draft introduced some improvements and clarifications over Draft 4. It was published in 2018 and includes support for new features like the format keyword, improved handling of default values, and better handling of $ref references.

# JSON Schema Draft 7: This draft further refined the specification and addressed some inconsistencies and ambiguities in Draft 6. It was also published in 2018 and is considered more stable and feature-complete compared to Draft 6. It introduced new features like const keyword and support for readOnly and writeOnly properties.

# JSON Schema Draft 2019-09: This draft introduced significant changes and improvements over Draft 7. It was published in 2019 and includes enhancements such as improved handling of const and enum, support for new formats, and better handling of $ref resolution.

# JSON Schema Draft 2020-12: This is the latest major version of JSON Schema as of my last update. It was published in 2020 and includes further improvements and refinements over Draft 2019-09. It introduced new keywords like unevaluatedProperties and unevaluatedItems, as well as support for new formats and features.

----------

# Go to this URL

https://json-schema.org/understanding-json-schema/reference/schema#schema

# and explain dialects in schema


# Let's go to some other JSON schema generator

https://transform.tools/json-to-json-schema


# Paste in the same TODO json

{
  "userId": 1,
  "id": 1,
  "title": "delectus aut autem",
  "completed": false
}

# Generate the JSON and notice that this used draft-07


--------


# One more JSON schema generator

https://jsonformatter.org/json-to-jsonschema

# Paste in the same TODO json

{
  "userId": 1,
  "id": 1,
  "title": "delectus aut autem",
  "completed": false
}

# Generate the JSON and notice that this used draft-06


----------

# One more

https://redocly.com/tools/json-to-json-schema/


# Paste in the same TODO json

{
  "userId": 1,
  "id": 1,
  "title": "delectus aut autem",
  "completed": false
}

# This does not specify the dialect at all

--------

# Back to IntelliJ - what dialects does RestAssured support?

# Press Cmd + Shift + O

# Select SchemaVersion under classes

# and show what versions are supported

# Every version has its own properties

# For example just go to this link

https://json-schema.org/understanding-json-schema/reference/array#additionalitems

# Show that different drafts behave in different ways


-----------------------------------------------
# Now let's build up the schema step by step (v02)

# Add the following fields

{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "$id": "https://example.com/todos_schema.json",
  "title": "Todo",
  "description": "A todo in the app"
}

------
# Notes

# $schema: specifies which draft of the JSON Schema standard the schema adheres to.
# $id: sets a URI for the schema. You can use this unique URI to refer to elements of the schema from inside the same document or from external JSON documents.
# title and description: state the intent of the schema. These keywords don’t add any constraints to the data being validated.
-----


# Run the test and show that the test succeeds - no validation yet!


# Now go to 

https://jsonplaceholder.typicode.com/todos/1

# Show that it returns a JSON object


# Now back to todos_schema.json

# Add this property

  "type": "object"

# Run the test and show that it passes

# Change type to

array
string
integer

# Run the code each time, it should fail


# IMPORTANT: Set the type back to "object"

# Now show the result of this

https://jsonplaceholder.typicode.com/todos/1

# It's an array


# Now in the code, just change the URL to

    private static final String TODOS_URL = "https://jsonplaceholder.typicode.com/todos/";

# Comment out pathParams


Test
    public void testSchemaValidation() {
        RestAssured
                .given()
//                    .pathParam("id", 1)
                .get(TODOS_URL)
                .then()
                    .body(matchesJsonSchemaInClasspath("todo_schema.json"));
    }

# Now run and show the test fails

# The response is an array but we said type is object

# In todo_schema.json - change type to "array"

# Run the code and it should pass

-----------
# Reset everything

# In todo_schema.json - change type to "object"


# Now in the code, just change the URL back to

    private static final String TODOS_URL = "https://jsonplaceholder.typicode.com/todos/{id}";

# Uncomment out pathParams


Test
    public void testSchemaValidation() {
        RestAssured
                .given()
                    .pathParam("id", 1)
                .get(TODOS_URL)
                .then()
                    .body(matchesJsonSchemaInClasspath("todo_schema.json"));
    }


# Run the code and show things pass

-----------

# Let's continue adding validations

# Add a property to be tested in the body

{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "$id": "https://example.com/todos_schema.json",
  "title": "Todo",
  "description": "A todo in the app",
  "type": "object",
  "properties": {
    "userId": {
      "type": "integer"
    }
  }
}

# Run the test and it passes

# Change the property to "blah"


  "properties": {
    "blah": {
      "type": "integer"
    }
  }

# The test will still pass, we haven't specified any property as required, so if "blah" is present it should be an integer, if absent then validation still passes

--------------
# Now let's add more properties

  "properties": {
    "userId": {
      "type": "integer"
    },
    "id": {
      "type": "integer"
    },
    "title": {
      "type": "string"
    },
    "completed": {
      "type": "boolean"
    }
  },


# run the test and show that it passes

# Now change the type of some properties

# first change to string

    "userId": {
      "type": "string"
    },

# Run and show failure

# Fix userId and change completed

    "userId": {
      "type": "integer"
    },

    "completed": {
      "type": "integer"
    }


# run and show

# fix all of them to be correct

  "properties": {
    "userId": {
      "type": "integer"
    },
    "id": {
      "type": "integer"
    },
    "title": {
      "type": "string"
    },
    "completed": {
      "type": "boolean"
    }
  },

------------------

# Now let's understand required properties

# Add this

    "blah": {
      "type": "boolean"
    }

# Run the test and the validation will pass

# Now let's specify which properties are required


  "required": [
    "userId",
    "id",
    "title",
    "completed"
  ]

# Schema should look like

{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "$id": "https://example.com/todos_schema.json",
  "title": "Todo",
  "description": "A todo in the app",
  "type": "object",
  "properties": {
    "userId": {
      "type": "integer"
    },
    "id": {
      "type": "integer"
    },
    "title": {
      "type": "string"
    },
    "completed": {
      "type": "boolean"
    },
    "blah": {
      "type": "boolean"
    }
  },
  "required": [
    "userId",
    "id",
    "title",
    "completed"
  ]
}

# run the test, everything should pass

# Add blah to the required properties list

  "required": [
    "userId",
    "id",
    "title",
    "completed",
    "blah"
  ]

# Now when you run you will encounter a failure

-----------
# additionalProperties


# Now remove "blah" from everywhere - schema should look like this

{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "$id": "https://example.com/todos_schema.json",
  "title": "Todo",
  "description": "A todo in the app",
  "type": "object",
  "properties": {
    "userId": {
      "type": "integer"
    },
    "id": {
      "type": "integer"
    },
    "title": {
      "type": "string"
    },
    "completed": {
      "type": "boolean"
    }
  },
  "required": [
    "userId",
    "id",
    "title",
    "completed"
  ]
}


# Remove the "completed" property from everywhere


{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "$id": "https://example.com/todos_schema.json",
  "title": "Todo",
  "description": "A todo in the app",
  "type": "object",
  "properties": {
    "userId": {
      "type": "integer"
    },
    "id": {
      "type": "integer"
    },
    "title": {
      "type": "string"
    }
  },
  "required": [
    "userId",
    "id",
    "title"
  ]
}

# run and show this passes - this is because additionalProperties = true by default

# now add this at the bottom - this is the default value

  "required": [
    "userId",
    "id",
    "title"
  ],
  "additionalProperties": true

# run and show things still pass

# but now change this

  "additionalProperties": false

# Run and show the failure (completed is present as an additional property)

# Go back to the working schema


{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "$id": "https://example.com/todos_schema.json",
  "title": "Todo",
  "description": "A todo in the app",
  "type": "object",
  "properties": {
    "userId": {
      "type": "integer"
    },
    "id": {
      "type": "integer"
    },
    "title": {
      "type": "string"
    },
    "completed": {
      "type": "boolean"
    }
  },
  "required": [
    "userId",
    "id",
    "title",
    "completed"
  ],
  "additionalProperties": false
}


-----------------------------------------------
# Additional constraints on strings and numbers (v03)

# Note that a number represents integers and floats

# Add a range constraint to id and userId

    "userId": {
      "type": "integer",
      "minimum": 1,
      "maximum": 10
    },
    "id": {
      "type": "integer",
      "minimum": 1,
      "maximum": 100
    },

# Switch over to the Java file

# Run the test on the todo id 1 - things should pass

# Change TODO id

.pathParam("id", 101)

# Run the test it should fail

# Change the test back to use 1

.pathParam("id", 1)

-------------

# Update the schema


    "userId": {
      "type": "integer",
      "minimum": 1,
      "exclusiveMinimum": true,
      "maximum": 10
    },
    "id": {
      "type": "integer",
      "minimum": 1,
      "maximum": 200
    },

# I've added exlusiveMinimum = true

# Show that this property is a boolean in draft 4

https://json-schema.org/understanding-json-schema/reference/numeric#range

# Come back to IntelliJ and run the test

# Test will fail

# Remove the exclusiveMinimum property

    "userId": {
      "type": "integer",
      "minimum": 1,
      "maximum": 10
    },
    "id": {
      "type": "integer",
      "minimum": 1,
      "maximum": 200
    },


--------
# Add a constraint to the title field

    "title": {
      "type": "string",
      "minLength": 5,
      "maxLength": 25
    },

# Run this should pass for TODO with id 1

# Change the TODO id to 5

.pathParam("id", 5)

# Run - this should fail

# Update the schema as below


    "title": {
      "type": "string",
      "minLength": 5,
      "maxLength": 2000
    },

# Run and show this passes


-----------------------------------------------
# Additional nested elements (v04)

# Go to

https://reqres.in/api/users/2

# Show the structure of the response

# Go to the Java file

public class RestAssuredTests {

    private static final String USERS_URL = "https://reqres.in/api/users/{id}";

    @Test
    public void testSchemaValidation() {
        RestAssured
                .given()
                    .pathParam("id", 5)
                .get(USERS_URL)
                .then()
                    .body(matchesJsonSchemaInClasspath("user_schema.json"));
    }

}

# Create a new schema file under resources

user_schema.json


{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "$id": "https://example.com/user_schema.json",
  "title": "User",
  "description": "A user in the app",
  "type": "object",
  "properties": {
    "data": {
      "type": "object"
    },
    "support": {
      "type": "object"
    }
  },
  "required": [
    "data",
    "support"
  ]
}

# Run and show - things should pass

# Update the "data" object


"data": {
      "type": "object",
      "properties": {
        "id": {
          "type": "integer"
        },
        "email": {
          "type": "string"
        },
        "first_name": {
          "type": "string"
        },
        "last_name": {
          "type": "string"
        },
        "avatar": {
          "type": "string"
        }
      },
      "required": [
        "id",
        "email",
        "first_name",
        "last_name",
        "avatar"
      ]
    },

# Update the support object

    "support": {
      "type": "object",
      "properties": {
        "url": {
          "type": "string"
        },
        "text": {
          "type": "string"
        }
      },
      "required": [
        "url",
        "text"
      ]
    }


# Run the code and show


-----------------------------------------------
# Specifying arrays (v05)

# Go to 

https://jsonplaceholder.typicode.com/todos

# Copy over a part of this 

[
    {
        "userId": 1,
        "id": 1,
        "title": "delectus aut autem",
        "completed": false
    },
    {
        "userId": 1,
        "id": 2,
        "title": "quis ut nam facilis et officia qui",
        "completed": false
    },
    {
        "userId": 1,
        "id": 3,
        "title": "fugiat veniam minus",
        "completed": false
    }
]

# Go to

https://www.liquid-technologies.com/online-json-to-schema-converter

# Paste it in and generate the schema

# Note that it generates the same schema for each element in the list

# Copy the schema over

# Go to IntelliJ

# Create a new schema under resources/

todos_schema.json

# Paste it there, and remove all the extra elements in the list

{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "type": "array",
  "items": [
    {
      "type": "object",
      "properties": {
        "userId": {
          "type": "integer"
        },
        "id": {
          "type": "integer"
        },
        "title": {
          "type": "string"
        },
        "completed": {
          "type": "boolean"
        }
      },
      "required": [
        "userId",
        "id",
        "title",
        "completed"
      ]
    }
  ]
}

# Run and show things work




















