#################################
Customizing Extent Reports
#################################

=> Before running tests here, please restart the Bugs API server so we start afresh

=> Open "ExtentTestNGListener.java" file and replace with the following code


# Have added color coding for pass, fail and skip
# And more info on the test failure like the actual cause and the stacktrace

# ExtentTestNGListener.java

package org.loonycorn.restassuredtests.listeners;

import com.aventstack.extentreports.ExtentReports;
import com.aventstack.extentreports.ExtentTest;
import com.aventstack.extentreports.Status;

import com.aventstack.extentreports.markuputils.ExtentColor;
import com.aventstack.extentreports.markuputils.MarkupHelper;

import io.restassured.response.Response;
import io.restassured.specification.QueryableRequestSpecification;
import org.testng.ITestContext;
import org.testng.ITestListener;
import org.testng.ITestResult;

import java.util.Arrays;

public class ExtentTestNGListener implements ITestListener {
    private static ExtentReports extent;

    @Override
    public void onStart(ITestContext context) {
        extent = ExtentManager.getExtentReports();
    }

    @Override
    public void onTestStart(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = extent.createTest(
                methodName, result.getMethod().getDescription());

        result.setAttribute(methodName + "-extentTest", extentTest);
    }

    @Override
    public void onTestSuccess(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");

        String log = "The test " + methodName + " was successful.";

        extentTest.pass(MarkupHelper.createLabel(log, ExtentColor.GREEN));

        logRequestAndResponseDetails(result);
    }

    @Override
    public void onTestFailure(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");

        String log = "The test " + methodName + " failed: " + result.getThrowable().getMessage();

        extentTest.fail(MarkupHelper.createLabel(log, ExtentColor.RED));
        extentTest.fail(MarkupHelper.createLabel(
                result.getThrowable().fillInStackTrace().toString(), ExtentColor.RED));

        logRequestAndResponseDetails(result);
    }

    @Override
    public void onTestSkipped(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");

        String log = "The test " + methodName + " was skipped.";

        extentTest.skip(MarkupHelper.createLabel(log, ExtentColor.YELLOW));
    }

    @Override
    public void onFinish(ITestContext context) {
        ExtentManager.flushExtentReports();
    }

    private void logRequestAndResponseDetails(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");
        QueryableRequestSpecification requestSpec = (QueryableRequestSpecification) result.getAttribute(
                methodName + "-requestSpec");

        if (requestSpec != null) {
            extentTest.log(Status.INFO, "Endpoint is: " + requestSpec.getURI());
            extentTest.log(Status.INFO, "Request body is: " + requestSpec.getBody());
        }

        Response response = (Response) result.getAttribute(methodName + "-response");

        if (response != null) {
            extentTest.log(Status.INFO, "Status is: " + response.getStatusCode());

            String[][] arrayHeaders = response.getHeaders().asList().stream().map(
                header -> new String[] {header.getName(), header.getValue()}).toArray(String[][] :: new);

            extentTest.log(Status.INFO, "Response headers are: " + Arrays.deepToString(arrayHeaders));
            extentTest.log(Status.INFO, "Response body is: " + response.getBody().prettyPrint());
        }
    }
}

# Make sure the BugsApiTests.java causes a test to fail
# In testGETRetrieveBugs (compare to size = 3)

        response.then()
                .statusCode(200)
                .body("size()", equalTo(3));




#################################

=> Run the BugsApiTests.java file
(Observe that the test fails and the report is generated in the "reports" folder)

=> Open and show the report
(Observe now we can see properly which test passed, failed and skipped with proper logs and color coding)


#################################


=> Open "ExtentManager.java" file and replace with the following code

# Here we are customizing the report name, theme, timestamp format and document title

# ExtentManager.java

# Add these after creating the Spark reporter

            sparkReporter.config().setTheme(Theme.DARK);
            sparkReporter.config().setTimeStampFormat("dd-mm-yyyy HH:mm:ss");
            sparkReporter.config().setDocumentTitle("Loonycorn Bugs Tracker Reports");
            sparkReporter.config().setReportName("Reports - Automated Test Results for Bugs API.");



=> Run the BugsApiTests.java file - the tests will still fail, that is fine

=> Open and show the report
(Observe now the report name, theme, timestamp format and document title are customized)


################################

# https://github.com/amod-mahajan/RetargetCommonRestAPIAutomationFramework/blob/master/src/main/java/restUtils/RestUtils.java
# https://www.youtube.com/watch?v=WwRssUku8gk&list=PL-a9eJ2NZlbRFnZbN8glYFGaEudds86-k&index=15

# Let's structure the request and response details better


# ExtentTestNGListener.java

# Update this method


    private void logRequestAndResponseDetails(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = (ExtentTest) result.getAttribute(methodName + "-extentTest");
        QueryableRequestSpecification requestSpec = (QueryableRequestSpecification) result.getAttribute(
                methodName + "-requestSpec");

        if (requestSpec != null) {
            extentTest.log(Status.INFO, "Endpoint is: " + requestSpec.getURI());

            if (requestSpec.getBody() != null) {
                extentTest.info(MarkupHelper.createCodeBlock(requestSpec.getBody(), CodeLanguage.JSON));
            }
        }

        Response response = (Response) result.getAttribute(methodName + "-response");

        if (response != null) {
            extentTest.log(Status.INFO, "Status is: " + response.getStatusCode());

            String[][] arrayHeaders = response.getHeaders().asList().stream().map(
                header -> new String[] {header.getName(), header.getValue()}).toArray(String[][] :: new);

            extentTest.info(MarkupHelper.createTable(arrayHeaders));

            if (response.getBody() != null) {
                extentTest.info(MarkupHelper.createCodeBlock(response.getBody().asPrettyString(), CodeLanguage.JSON));
            }
        }
    }


################################

=> Run the BugsApiTests.java file

=> The tests should still fail

=> Open and show the report (show each response, pass, fail, skip)
(Observe now we can see the request and response details in the report with better formatting)

################################

=> Restart the Bugs API server so we start afresh

=> Run the tests everything should pass


=> Open and show the report (show each response, pass, fail, skip)
(Observe now we can see the request and response details in the report with better formatting)


################################

=> Open "ExtentTestNGListener.java" file and replace with the following code

# ExtentTestNGListener.java

    @Override
    public void onTestStart(ITestResult result) {
        String methodName = result.getMethod().getMethodName();

        ExtentTest extentTest = extent.createTest(
                methodName, result.getMethod().getDescription())
                    .assignAuthor("Loonycorn")
                    .assignCategory("API Functionality Tests");;

        result.setAttribute(methodName + "-extentTest", extentTest);
    }

################################

=> Run the BugsApiTests.java file

=> Open and show the report
(Observe now we can see the author and category details in the report)





















