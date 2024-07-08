#################################
Triggering Jenkins on Push
#################################
# https://www.youtube.com/watch?v=okmh53oGlak

=> Click on "BugsApiTestsMaven" -> "Configure"

=> Click "Build Triggers"

[TICK] "Poll SCM"


=> Click on the ? next to "Poll SCM" to show that it means

* * * * * 
(Every minute)

=> Click on "Apply" -> "Save"

=> Click on "Git Polling Log" to see the logs

################################# (V2)

# In IntelliJ IDEA
=> Open "BugsApiTests" -> "src" -> "test" -> "java" -> "com.loonycorn" -> "BugsApiTests" -> "BugsApiTests.java"

# Add new code to check if the bugs count is 0

@Test(dependsOnMethods = "testPATCHUpdateBugTwo")
public void testDELETEAllBugs() {


    // Same as before

    RestAssured
            .given()
            .contentType(ContentType.JSON)
            .when()
            .get(BUGS_URL)
            .then()
            .statusCode(200)
            .body("size()", equalTo(0));
}



=> Click on "Git" -> "Commit"

Commit Message: Tweaked delete all bugs test to confirm deletion

=> Click on "Commit and Push"

=> Click on "Push"

=> Go to the repository and show the push was successful (click on commits on the top right)

#################################

# In Jenkins

=> Click on "BugsApiTestsMaven"
(Observe that the tests have started running)

=> Click on "Git Polling Log" to see the logs (Changes found)

=> Click through and show all tests pass


=> Go to "Configure"


=> Click "Build Triggers"

[UNTICK] "Poll SCM"

=> Click on "Apply" -> "Save"














