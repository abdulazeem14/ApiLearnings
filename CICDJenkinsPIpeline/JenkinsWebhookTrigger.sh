#################################
Trigger Jenkins on Push using Webhook
#################################
# https://www.devopsschool.com/blog/how-to-build-when-a-change-is-pushed-to-github-in-jenkins/

# Insted of Jenkins polling the GitHub repository
# every few minutes like we did in our previous demo, 
# we can configure Jenkins to listen to GitHub Webhook and trigger the build

# In order to use the GitHub Webhook with Jenkins
# we need to have our Jenkins server in public as
# well as our api shall be publicily accessible.

=> Open and show in browser "https://ngrok.com/"

=> Click "Login" -> Login using loony.test.001@gmail.com (use Google login)

=> Click on Windows and show how you can set up ngrok on Windows, scroll

=> Click on Linux and show how you can set up ngrok on Linux, scroll

=> Click on MacOS and show how you can set up ngrok on MacOS, scroll


# In "Setup & Installation" section
=> Click "Homebrew" and follow the instructions to install ngrok

# In terminal
$ brew install ngrok/ngrok/ngrok

$ ngrok --version

$ ngrok --help

# Copy over this command with the token from the ngrok install page

$ ngrok config add-authtoken 2czO6thehx9x7xmvEN5ohH0xaOE_6J4BebjpKuuT8G4w3bTZ3

$ ngrok http http://localhost:8090
# https://7ff5-49-205-137-14.ngrok-free.app

# On the ngrok page - go to "Endpoints" from the links on the left

# Show that your endpoint is here

# Click on the endpoint and show that it leads to the Bugs API server

# In browser
=> In browser goto "https://7ff5-49-205-137-14.ngrok-free.app"
(Observe we get a initial page saying "ngrok" -> "Visit Site")

username: loonycorn
password: password

=> Click on "Build Now" button
(Observe all the tests are passing)

# In browser
=> Open "github.com" -> "bugs-api-tests-repo"

=> Click on "Settings" tab

=> Click on "Webhooks" tab -> "Add webhook"

Payload URL: https://7ff5-49-205-137-14.ngrok-free.app/github-webhook/
Content type: application/x-www-form-urlencoded

[TICK] Enable SSL verification
[TICK] Just the push event
[TICK] Active

=> Click "Add webhook"

# Go back to Jenkins
=> Click "BugsApiTestsMaven" -> "Configure" -> "Build Triggers"
[TICK] "GitHub hook trigger for GITScm polling"

=> Click on the ? next to GitHub hook trigger for GITScm polling and show what it means


=> Click "Apply" -> "Save"



# Go back to IntelliJ IDEA

=> Modify the file "src/test/java/com/loonycorn/BugsApiTests.java"

=> Just delete the extra test we added earlier

################################# (V3)

=> Delete this


    # @Test
    # public void testPOSTCreateBugThree() {
    #     BugRequestBody bug = new BugRequestBody(
    #             "Mohamed Ali", 1, "High",
    #             "Cart is glitchy", false
    #     );

    #     ResponseSpecification responseSpec = createResponseSpec(bug);

    #     RestAssured
    #             .given()
    #             .body(bug)
    #             .when()
    #             .post()
    #             .then()
    #             .statusCode(201)
    #             .spec(responseSpec);
    # }

=> Change the depends on for testGETRetrieveBugs and compare to two bugs

 @Test(dependsOnMethods = {"testPOSTCreateBugOne", "testPOSTCreateBugTwo"})
    public void testGETRetrieveBugs() {
        RestAssured
                .get()
                .then()
                    .statusCode(200)
                    .body("size()", equalTo(2));
    }


#################################


=> Click "Git" -> "Commit"

Commit Message: Deleted extra test

=> Click "Commit & Push"


# In Jenkins
=> Refresh the page
# Observe the build is triggered automatically

=> Click and show that we have only two create bug tests


















