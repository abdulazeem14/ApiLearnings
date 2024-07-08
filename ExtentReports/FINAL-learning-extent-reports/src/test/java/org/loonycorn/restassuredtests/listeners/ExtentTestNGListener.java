package org.loonycorn.restassuredtests.listeners;

import com.aventstack.extentreports.ExtentReports;
import com.aventstack.extentreports.ExtentTest;
import com.aventstack.extentreports.Status;

import com.aventstack.extentreports.markuputils.CodeLanguage;
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
                methodName, result.getMethod().getDescription())
                    .assignAuthor("Loonycorn")
                    .assignCategory("API Functionality Tests");;

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
}