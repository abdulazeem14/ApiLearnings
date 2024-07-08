-----------------------------------------------
Serializing and deserializing using POJOs
-----------------------------------------------

# Go to this API and show

https://fakestoreapi.com/users/3


-----------------------------------------------
# Show just parsing and validating the JSON response (v01)

package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_USER_URL = "https://fakestoreapi.com/users/{id}";

    @Test
    public void testBody() {
        RestAssured
                .given()
                    .pathParam("id", 3)
                .when()
                    .get(STORE_USER_URL)
                .then()
                    .body("id", equalTo(3))
                    .body("email", equalTo("kevin@gmail.com"))
                    .body("username", equalTo("kevinryan"))
                    .body("address.city", equalTo("Cullman"))
                    .body("address.street", equalTo("Frances Ct"))
                    .body("address.number", equalTo(86))
                    .body("address.zipcode", equalTo("29567-1452"))
                    .body("address.geolocation.lat", equalTo("40.3467"))
                    .body("address.geolocation.long", equalTo("-30.1310"))
                    .body("name.firstname", equalTo("kevin"))
                    .body("name.lastname", equalTo("ryan"));
    }
}

# Run and show

# Very tedious, have to keep specifying the complete path of the properties

-----------------------------------------------
# Deserialize the response to a generic type (v02)
# You can extract the root list to a List<Map<String, Object>> (or a any generic container of choice) using the TypeRef:

import io.restassured.RestAssured;
import io.restassured.common.mapper.TypeRef;
import org.testng.annotations.Test;

import java.util.Map;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_USER_URL = "https://fakestoreapi.com/users/{id}";

    @Test
    public void testBody() {
        Map<String, Object> user = RestAssured
                .given()
                    .pathParam("id", 3)
                .when()
                    .get(STORE_USER_URL).as(new TypeRef<>() {
                });

        assertThat((Integer) user.get("id"), equalTo(3));
        assertThat(user.get("email"), equalTo("kevin@gmail.com"));
        assertThat(user.get("username"), equalTo("kevinryan"));
        assertThat(user.get("phone"), equalTo("1-567-094-1345"));

        Map<String, Object> address = (Map<String, Object>) user.get("address");

        assertThat(address.get("city"), equalTo("Cullman"));
        assertThat(address.get("street"), equalTo("Frances Ct"));
        assertThat((Integer) address.get("number"), equalTo(86));
        assertThat(address.get("zipcode"), equalTo("29567-1452"));

    }
}








-----------------------------------------------
# Set up a class to represent the user (v03)

# In the package test/java/org/loonycorn/restassured

# Right-click and create a new package "model"

# In the model/ package right-click and create a new class

User.java

# Add this code to the class


public class User {

    private int id;
    private String email;
    private String username;
    private String phone;


}


# Right-click -> Generate -> Getter and setter -> Select All -> Generate

# Class should now look like this


public class User {

    private int id;
    private String email;
    private String username;
    private String phone;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

}


# Set the RestAssuredTests.java class up as follows

package org.loonycorn.restassuredtests;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.loonycorn.restassuredtests.model.User;
import org.testng.annotations.Test;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_USER_URL = "https://fakestoreapi.com/users/{id}";

    @Test
    public void testBody() throws JsonProcessingException {
        Response response = RestAssured
                .given()
                    .pathParam("id", 3)
                .when()
                    .get(STORE_USER_URL)
                .then()
                    .extract().response();

        ObjectMapper objectMapper = new ObjectMapper();
        User user = objectMapper.readValue(response.asString(), User.class);

        assertThat(user.getId(), equalTo(3));
        assertThat(user.getEmail(), equalTo("kevin@gmail.com"));
        assertThat(user.getUsername(), equalTo("kevinryan"));
        assertThat(user.getPhone(), equalTo("1-567-094-1345"));
    }
}


# Run this - this will throw an error

# Note the error about properties that have not been ignored

# Show this URL

https://fakestoreapi.com/users/3

# We've only have a few of the properties in the class

# Go to User.java

# Add this and import the class as well

@JsonIgnoreProperties(ignoreUnknown = true)


# Now go back and run the tests - should pass!


-----------------------------------------------
# Mapping field names to JSON properties (v04)

# Now let's say that we want the variables and the getters and setters in the User class to be different from the JSON property names

# Go to User.java

# Right-click on email -> Refactor -> Rename -> emailAddress

# Right-click on phone -> Refactor -> Rename -> phoneNumber

# Make sure to rename the getters and setters

# Now go back and run the test (it's references to these methods would have been updated as well)

# The test will fail because our field names DO NOT MATCH the JSON properties

# Go to User.java and add these

    @JsonProperty("email")

    @JsonProperty("phone")

# Now run the tests again - they should pass



-----------------------------------------------
# Deserializing without the object mapper (v05)

# Can use the as(User.class) in the response to deserialize

package org.loonycorn.restassuredtests;

import com.fasterxml.jackson.core.JsonProcessingException;
import io.restassured.RestAssured;
import org.loonycorn.restassuredtests.model.User;
import org.testng.annotations.Test;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_USER_URL = "https://fakestoreapi.com/users/{id}";

    @Test
    public void testBody() {
        User user = RestAssured
                .given()
                    .pathParam("id", 3)
                .when()
                    .get(STORE_USER_URL).as(User.class);

        assertThat(user.getId(), equalTo(3));
        assertThat(user.getEmailAddress(), equalTo("kevin@gmail.com"));
        assertThat(user.getUsername(), equalTo("kevinryan"));
        assertThat(user.getPhoneNumber(), equalTo("1-567-094-1345"));
    }
}



-----------------------------------------------
# Deserializing with nested objects (v06)

# Go to 

https://fakestoreapi.com/users/3

# And show the nested "address" inside the User

# Now in IntelliJ go to org.restassured.tests.model and create a new file Address.java


package org.loonycorn.restassuredtests.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

@JsonIgnoreProperties({ "geolocation" })
public class Address {
    private String city;
    private String street;
    private int number;
    private String zipcode;

    public String getCity() {
        return city;
    }

    public void setCity(String city) {
        this.city = city;
    }

    public String getStreet() {
        return street;
    }

    public void setStreet(String street) {
        this.street = street;
    }

    public int getNumber() {
        return number;
    }

    public void setNumber(int number) {
        this.number = number;
    }

    public String getZipcode() {
        return zipcode;
    }

    public void setZipcode(String zipcode) {
        this.zipcode = zipcode;
    }
}


# Now go to User.java

# Add the address field

    private Address address;


# Add getters and setters for the address at the bottom


    public Address getAddress() {
        return address;
    }

    public void setAddress(Address address) {
        this.address = address;
    }

# Now go to the RestAssuredTests.java

# Additional assertions to check the address

        assertThat(user.getAddress().getCity(), equalTo("Cullman"));
        assertThat(user.getAddress().getStreet(), equalTo("Frances Ct"));
        assertThat(user.getAddress().getNumber(), equalTo(86));
        assertThat(user.getAddress().getZipcode(), equalTo("29567-1452"));


# Run the test and show that it works

# Change some property that you are comparing with in the test

# Run and show the test fails

# Change the property back


-----------------------------------------------
# Deserializing nested entities using unmarshalling (v07)

# Show the structure of the response

https://fakestoreapi.com/users/3

# Show how first name and last name is nested within the response

# Now add the firstname and lastname property as top-level properties in User

# Add just under "id"


    private String firstname;
    private String lastname;

# Add a getter and setter under the getter and setter for "id"


    public String getFirstname() {
        return firstname;
    }

    public void setFirstname(String firstname) {
        this.firstname = firstname;
    }

    public String getLastname() {
        return lastname;
    }

    public void setLastname(String lastname) {
        this.lastname = lastname;
    }


# Go to RestAssuredTests.java and add tests


        assertThat(user.getFirstname(), equalTo("kevin"));
        assertThat(user.getLastname(), equalTo("ryan"));

# Run and show that the tests fail - this is because our class does not match the structure of the JSON object


-----

# Now in User.java add this


    @JsonProperty("name")
    public void deserializeAndPopulateName(Map<String, ?> nameMap) {
        firstname = (String) nameMap.get("firstname");
        lastname = (String) nameMap.get("lastname");
    }


# Now go to RestAssured.java and run the tests, things will pass!


-----------------------------------------------
# Using Lombok to reduce boilerplate code (v08)


# Go to 

https://mvnrepository.com/

# Search for 

lombok

# Copy over the dependency

    <!-- https://mvnrepository.com/artifact/org.projectlombok/lombok -->
    <dependency>
      <groupId>org.projectlombok</groupId>
      <artifactId>lombok</artifactId>
      <version>1.18.30</version>
      <scope>provided</scope>
    </dependency>


# Reload the project

# Now remove all the getters and setters from User.java and add the @Data annotation


@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class User {

    private int id;

    private String firstname;
    private String lastname;

    @JsonProperty("email")
    private String emailAddress;
    private String username;
    @JsonProperty("phone")
    private String phoneNumber;

    private Address address;

    @JsonProperty("name")
    public void deserializeAndPopulateName(Map<String, ?> nameMap) {
        firstname = (String) nameMap.get("firstname");
        lastname = (String) nameMap.get("lastname");
    }

}


# Do the same with Address.java

package org.loonycorn.restassuredtests.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;

@Data
@JsonIgnoreProperties({ "geolocation" })
public class Address {
    private String city;
    private String street;
    private int number;
    private String zipcode;
}


# Go to RestAssuredTests.java - there are redlines but things will compile

# Now and run the tests

# Everything should pass!


# Note all the red lines indicating that IntelliJ has not understood our Lombok object - we need to add a plugin for that

# Go to Preferences -> Plugins

# Search for Lombok

# Install the plugin - the red lines should disappear

# Now and run the tests and things should pass again


-----------------------------------------------
# Deserializing a list of users (v09)


package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import org.loonycorn.restassuredtests.model.User;
import org.testng.annotations.Test;

import java.util.Arrays;
import java.util.List;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_USERS_URL = "https://fakestoreapi.com/users/";

    @Test
    public void testBody() {
        List<User> users = Arrays.asList(RestAssured
                .get(STORE_USERS_URL).as(User[].class));

        assertThat(users.size(), equalTo(10));

        assertThat(users.get(2).getEmailAddress(), equalTo("kevin@gmail.com"));
        assertThat(users.get(2).getUsername(), equalTo("kevinryan"));
        assertThat(users.get(2).getPhoneNumber(), equalTo("1-567-094-1345"));

        assertThat(users.get(2).getFirstname(), equalTo("kevin"));
        assertThat(users.get(2).getLastname(), equalTo("ryan"));

        assertThat(users.get(2).getAddress().getCity(), equalTo("Cullman"));
        assertThat(users.get(2).getAddress().getStreet(), equalTo("Frances Ct"));
        assertThat(users.get(2).getAddress().getNumber(), equalTo(86));
        assertThat(users.get(2).getAddress().getZipcode(), equalTo("29567-1452"));

    }
}


-----------------------------------------------
# Serializing data for POST requests (v10)

# Under org.loonycorn.restassured.model add a new model class

Product.java


package org.loonycorn.restassuredtests.model;


import lombok.Data;
import lombok.AllArgsConstructor;

@AllArgsConstructor
@Data
public class Product {

    private String title;
    private float price;
    private String description;
    private String image;
    private String category;
}


# Update the RestAssuredTests.java

package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.loonycorn.restassuredtests.model.Product;
import org.loonycorn.restassuredtests.model.User;
import org.testng.annotations.Test;

import java.util.Arrays;
import java.util.List;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_PRODUCTS_URL = "https://fakestoreapi.com/products";

    @Test
    public void testBody() {

        Product product = new Product(
            "test product",
            13.5f,
            "lorem ipsum set",
            "https://i.pravatar.cc",
            "electronics"
        );

        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(product)
                .when()
                    .post(STORE_PRODUCTS_URL)
                .then()
                    .statusCode(200)
                    .body("id", notNullValue())
                    .body("title", equalTo(product.getTitle()))
                    .body("price", equalTo(product.getPrice()))
                    .body("description", equalTo(product.getDescription()))
                    .body("image", equalTo(product.getImage()))
                    .body("category", equalTo(product.getCategory()));
    }
}



-----------------------------------------------
# Serializing data for POST requests - flattening data (v11)


# Under org.loonycorn.restassured.model add a new model class

# ProductDetails.java


package org.loonycorn.restassuredtests.model;

import lombok.AllArgsConstructor;
import lombok.Data;

@AllArgsConstructor
@Data
public class ProductDetails {
    private String description;
    private String image;
}


# Change Product.java

package org.loonycorn.restassuredtests.model;

import lombok.Data;
import lombok.AllArgsConstructor;

@AllArgsConstructor
@Data
public class Product {

    private String title;
    private float price;
    private String category;

    private ProductDetails productDetails;
}


# Update RestAssuredTests.java

package org.loonycorn.restassuredtests;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import org.loonycorn.restassuredtests.model.Product;
import org.loonycorn.restassuredtests.model.ProductDetails;
import org.testng.annotations.Test;

import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_PRODUCTS_URL = "https://fakestoreapi.com/products";

    @Test
    public void testBody() {

        ProductDetails details = new ProductDetails("lorem ipsum set", "https://i.pravatar.cc");
        Product product = new Product("test product", 13.5f, "electronics", details);

        RestAssured
                .given()
                    .contentType(ContentType.JSON)
                    .body(product)
                .when()
                    .post(STORE_PRODUCTS_URL)
                .then()
                    .statusCode(200)
                    .body("id", notNullValue())
                    .body("title", equalTo(product.getTitle()))
                    .body("price", equalTo(product.getPrice()))
                    .body("description", equalTo(product.getProductDetails().getDescription()))
                    .body("image", equalTo(product.getProductDetails().getImage()))
                    .body("category", equalTo(product.getCategory()));
    }
}


# Run the tests and you will get an error

# Comment out the line in error

                    .body("description", equalTo(product.getProductDetails().getDescription()))

# Run again, the image will throw an error

# Add a peek() just after the post()

                .when()
                    .post(STORE_PRODUCTS_URL)
                    .peek()


# Run the test and show that "description" and "image" are null

# Now go to Product.java

import com.fasterxml.jackson.annotation.JsonUnwrapped;


    @JsonUnwrapped
    private ProductDetails productDetails;

# Run the test and everything works

# Note that the properties have been flattened into the outer object























