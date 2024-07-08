-----------------------------------------------
Validating Response Body
-----------------------------------------------

# Go to 

https://fakestoreapi.com/users/1

# Change users to 3, 4

# Note the structure


# Back to IntelliJ

----------------------------------------------
# Can test body() as string (v01)
# Not recommended at all


import io.restassured.RestAssured;
import io.restassured.response.ResponseBody;
import org.testng.annotations.Test;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;

public class RestAssuredTests {

    private static final String STORE_USER_URL = "https://fakestoreapi.com/users/{id}";

    @Test
    public void testBodyAsString() {
        ResponseBody<?> responseBody = RestAssured
                .given()
                    .pathParam("id", 1)
                .when()
                    .get(STORE_USER_URL);

        String responseBodyString = responseBody.asString();

        assertThat(responseBodyString.contains("address"), equalTo(true));
        assertThat(responseBodyString.contains("geolocation"), equalTo(true));
        assertThat(responseBodyString.contains("id"), equalTo(true));
        assertThat(responseBodyString.contains("email"), equalTo(true));
    }

}


----------------------------------------------
# Access elements using JSONpath (v02)

# Change the code

    @Test
    public void testBodyUsingJsonPath() {
        ResponseBody<?> responseBody = RestAssured
                .given()
                    .pathParam("id", 1)
                .when()
                    .get(STORE_USER_URL);

        JsonPath jsonPath = responseBody.jsonPath();

        Map<String, ?> bodyJson = jsonPath.get();
        System.out.println(bodyJson);

    }


# Run and show

# Add more

        Map<String, ?> addressJson = jsonPath.get("address");
        System.out.println(addressJson);

# run and show

# Access further nested elements

        Map<String, ?> geolocationJson = jsonPath.get("address.geolocation");
        System.out.println(geolocationJson);

# Run and show

        String lat = jsonPath.get("address.geolocation.lat");
        System.out.println(lat);

# Run and show


----------------------------------------------
# Test elements using JSONpath (v03)

# Note that address.number returns an int


    @Test
    public void testBody() {
        ResponseBody<?> responseBody = RestAssured
                .given()
                    .pathParam("id", 1)
                .when()
                    .get(STORE_USER_URL);

        JsonPath jsonPath = responseBody.jsonPath();

        assertThat(jsonPath.get("email"), equalTo("john@gmail.com"));
        assertThat(jsonPath.get("username"), equalTo("johnd"));

        assertThat(jsonPath.get("name.firstname"), equalTo("john"));
        assertThat(jsonPath.get("name.lastname"), equalTo("doe"));

        assertThat(jsonPath.get("address.city"), equalTo("kilcoole"));
        assertThat(jsonPath.get("address.street"), equalTo("new road"));
        assertThat(jsonPath.get("address.number"), equalTo(7682));

    }

----------------------------------------------
# Validate elements using body() (v04)


    @Test
    public void testBody() {
        RestAssured
                .given()
                    .pathParam("id", 1)
                .when()
                    .get(STORE_USER_URL)
                .then()
                    .body("id", equalTo(1))
                    .body("email", equalTo("john@gmail.com"))
                    .body(containsStringIgnoringCase("zipcode"))
                    .body(allOf(containsString("name"), containsString("address")));
    }


# Run and show



----------------------------------------------
# Validate nested elements using body() (v05)


    @Test
    public void testBody() {
        RestAssured
                .given()
                    .pathParam("id", 2)
                .when()
                    .get(STORE_USER_URL)
                .then()
                    .body("address.city", equalTo("kilcoole"))
                    .body("address.street", equalTo("Lovers Ln"))
                    .body("address.number", equalTo(7267))
                    .body("address.zipcode", equalTo("12926-3874"))
                    .body("address.geolocation.lat", equalTo("-37.3159"))
                    .body("address.geolocation.long", equalTo("81.1496"))
                    .body("name.firstname", equalTo("david"))
                    .body("name.lastname", equalTo("morrison"));
    }

# Run and show

# Quite ugly, lot's of repetition


    @Test
    public void testBody() {
        RestAssured
                .given()
                    .pathParam("id", 2)
                .when()
                    .get(STORE_USER_URL)
                .then()
                    .rootPath("address")
                        .body("city", equalTo("kilcoole"))
                        .body("street", equalTo("Lovers Ln"))
                        .body("number", equalTo(7267))
                        .body("zipcode", equalTo("12926-3874"))
                        .body("geolocation.lat", equalTo("-37.3159"))
                        .body("geolocation.long", equalTo("81.1496"))
                    .rootPath("name")
                        .body("firstname", equalTo("david"))
                        .body("lastname", equalTo("morrison"));
    }

# Run and show


# Can improve this further

                    .rootPath("address")
                        .body("city", equalTo("kilcoole"))
                        .body("street", equalTo("Lovers Ln"))
                        .body("number", equalTo(7267))
                        .body("zipcode", equalTo("12926-3874"))
                    .rootPath("address.geolocation")
                        .body("lat", equalTo("-37.3159"))
                        .body("long", equalTo("81.1496"))
                    .rootPath("name")
                        .body("firstname", equalTo("david"))
                        .body("lastname", equalTo("morrison"));

# Run and show

# Remove the root path

                    .noRootPath()
                        .body("email", matchesPattern("[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}"))
                        .body("phone", equalTo("1-570-236-7033"));


# Run and show


----------------------------------------------
# Validate anonymous JSON root (v06)

# Go to

https://fakestoreapi.com/products/categories

# Show the result

# Back to IntelliJ


public class RestAssuredTests {

    private static final String STORE_CATEGORIES_URL = "https://fakestoreapi.com/products/categories";

    @Test
    public void testBody() {
        RestAssured
                .get(STORE_CATEGORIES_URL)
                .then()
                    .body("$", hasItem("electronics"));
    }

}

# Run and show

# Can use the empty string also to access the root

    @Test
    public void testBody() {
        RestAssured
                .get(STORE_CATEGORIES_URL)
                .then()
                    .body("$", hasItem("electronics"))
                    .body("$", hasItems("jewelery", "men's clothing", "electronics"))
                    .body("", contains(
                            "electronics", "jewelery", "men's clothing", "women's clothing"))
                    .body("", containsInAnyOrder(
                            "men's clothing", "women's clothing", "electronics", "jewelery"));
    }


----------------------------------------------
# Validating lists of items (v07)


# Go to

https://fakestoreapi.com/products/category/electronics

# Show the response

# Back to IntelliJ


public class RestAssuredTests {

    private static final String STORE_ELECTRONICS_URL = "https://fakestoreapi.com/products/category/electronics";

    @Test
    public void testBody() {
        RestAssured
                .get(STORE_ELECTRONICS_URL)
                .then()
                    .body("[0]", notNullValue())
                    .body("[2]", notNullValue());
    }

}

# Run and show

# Add one more call

        RestAssured
                .get(STORE_ELECTRONICS_URL)
                .then()
                    .body("[0]", notNullValue())
                    .body("[2]", notNullValue())
                    .body("[100]", notNullValue());

# Test will fail as we now have a null value at index 100

# Remove the last index 100 look up

# Add a new method


    @Test
    public void testListElementContents() {
        RestAssured
                .get(STORE_ELECTRONICS_URL)
                .then()
                .body("[0].id", equalTo(9))
                .body("[0].title", containsStringIgnoringCase("hard drive"))
                .body("[0].price", equalTo(64))
                .body("[0].rating.rate", lessThanOrEqualTo(5f))
                .body("[0].rating.count", greaterThan(200));
    }

# Run and show

# Add to the same method, multiple element testing


    @Test
    public void testListElementContents() {
        RestAssured
                .get(STORE_ELECTRONICS_URL)
                .then()
                .body("id[0]", equalTo(9))
                .body("title[0]", containsStringIgnoringCase("hard drive"))
                .body("price[0]", equalTo(64))
                .body("rating.rate[0]", lessThanOrEqualTo(5f))
                .body("rating.count[0]", greaterThan(200))
                .body("id[2]", equalTo(11))
                .body("title[2]", containsString("256GB SSD"))
                .body("price[2]", equalTo(109))
                .body("rating.rate[2]", lessThanOrEqualTo(5f))
                .body("rating.count[2]", greaterThan(300));
    }

# Run and show

# Can rewrite this to be more readable

    @Test
    public void testListElementContents() {
        RestAssured
                .get(STORE_ELECTRONICS_URL)
                .then()
                .rootPath("[0]")
                    .body("id", equalTo(9))
                    .body("title", containsStringIgnoringCase("hard drive"))
                    .body("price", equalTo(64))
                    .body("rating.rate", lessThanOrEqualTo(5f))
                    .body("rating.count", greaterThan(200))
                .rootPath("[2]")
                    .body("id", equalTo(11))
                    .body("title", containsString("256GB SSD"))
                    .body("price", equalTo(109))
                    .body("rating.rate", lessThanOrEqualTo(5f))
                    .body("rating.count", greaterThan(300));
    }

# Run and show


# Add a new method


    @Test
    public void testFieldContentsInLists() {
        RestAssured
                .get(STORE_ELECTRONICS_URL)
                .then()
                .body("id", equalTo(9));
    }

# Run and show that it fails

# This accesses the ids for all elements returned


    @Test
    public void testFieldContentsInLists() {
        RestAssured
                .get(STORE_ELECTRONICS_URL)
                .then()
                .body("title", equalTo(9));
    }

# This returns a list of all titles


# Change the code to


    @Test
    public void testFieldContentsInLists() {
        RestAssured
                .get(STORE_ELECTRONICS_URL)
                .then()
                .body("id", hasItems(9, 12, 13, 14))
                .body("id", containsInAnyOrder(9, 12, 13, 14, 11, 10));
    }

# Run and show - this will work

# Expand the test



    @Test
    public void testFieldContentsInLists() {
        RestAssured
                .get(STORE_ELECTRONICS_URL)
                .then()
	                .body("id", hasItems(9, 12, 13, 14))
	                .body("id", containsInAnyOrder(9, 12, 13, 14, 11, 10))
	                .body("title", hasItem(containsString("SSD")))
	                .body("image", everyItem(endsWith(".jpg")))
	                .body("category", everyItem(equalTo("electronics")))
	                .body("rating.rate", everyItem(allOf(greaterThan(0f), lessThan(5f))));
    }


----------------------------------------------
# Validating lists of items - different example (v08)

# Go to

https://reqres.in/api/users?page=1

# Show the response

# Set up the test

public class RestAssuredTests {

    private static final String USERS_URL = "https://reqres.in/api/users?page=1";

    @Test
    public void testBody() {
        RestAssured
                .get(USERS_URL)
                .then()
                    .rootPath("data[0]")
                        .body("id", equalTo(1))
                        .body("first_name", equalTo("George"))
                .noRootPath()
                        .body("data.first_name[1]", equalTo("Janet"))
                        .body("data.email[1]", equalTo("janet.weaver@reqres.in"))
                        .body("data.last_name", hasItems("Holt", "Morris"))
                        .body("data.last_name", hasItems(startsWith("Ram")));
    }

}


# Run and show


----------------------------------------------
# Validating response using response aware matcher (v09)


public class RestAssuredTests {

    private static final String USERS_URL = "https://reqres.in/api/users?page=1";

    @Test
    public void testBody() {
        RestAssured
                .get(USERS_URL)
                .then()
                    .body("data.email[0]", response ->
                            containsStringIgnoringCase(response.body().jsonPath().get("data.first_name[0]")));
    }

}


# Expand the example a little bit


    @Test
    public void testBody() {
        RestAssured
                .get(USERS_URL)
                .then()
                    .body("data.email[0]", response ->
                            containsStringIgnoringCase(response.body().jsonPath().get("data.first_name[0]")))
                    .body("data.email[0]", response ->
                            containsStringIgnoringCase(response.body().jsonPath().get("data.last_name[0]")));
    }


----------------------------------------------
# Extracting values from the response after validation (v10)



public class RestAssuredTests {

    private static final String POSTS_URL = "https://jsonplaceholder.typicode.com/posts";

    private static final String COMMENTS_URL = "https://jsonplaceholder.typicode.com/posts/{id}/comments";

    @Test
    public void testExtract() {
        Integer postId = RestAssured
                .get(POSTS_URL)
                .then()
                    .body("size()", equalTo(100))
                    .extract()
                    .path("id[2]");

        RestAssured
                .given()
                    .pathParam("id", postId)
                .when()
                    .get(COMMENTS_URL)
                .then()
                    .body("size()", equalTo(5));

    }

}























