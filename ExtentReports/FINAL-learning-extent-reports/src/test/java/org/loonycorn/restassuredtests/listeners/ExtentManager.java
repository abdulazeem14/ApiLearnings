package org.loonycorn.restassuredtests.listeners;

import com.aventstack.extentreports.ExtentReports;
import com.aventstack.extentreports.reporter.ExtentSparkReporter;
import com.aventstack.extentreports.reporter.configuration.Theme;

import java.io.File;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.Date;

public class ExtentManager {
    private static ExtentReports extent;

     public synchronized static ExtentReports getExtentReports() {
        if (extent == null) {
            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd_HHmmss");
            String timestamp = formatter.format(new Date());
            String filename = "bugs-report-" + timestamp + ".html";

            File reportsDir = new File(Paths.get(System.getProperty("user.dir"), "reports").toString());
            if (!reportsDir.exists()) {
                reportsDir.mkdirs();
            }

            String filePath = Paths.get(reportsDir.getAbsolutePath(), filename).toString();

            ExtentSparkReporter sparkReporter = new ExtentSparkReporter(filePath);

            sparkReporter.config().setTheme(Theme.DARK);
            sparkReporter.config().setTimeStampFormat("dd-mm-yyyy HH:mm:ss");
            sparkReporter.config().setDocumentTitle("Loonycorn Bugs Tracker Reports");
            sparkReporter.config().setReportName("Reports - Automated Test Results for Bugs API.");

            extent = new ExtentReports();
            extent.attachReporter(sparkReporter);
        }

        return extent;
    }

    public synchronized static void flushExtentReports() {
         if (extent != null) {
             extent.flush();
         }
    }
}