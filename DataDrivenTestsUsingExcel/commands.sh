-----------------------------------------------
Data-driven tests using Excel
-----------------------------------------------


-----------------------------------------------
Feeding data from Excel - v01
-----------------------------------------------


# Go to Maven

https://mvnrepository.com/

# Search for 

apache poi

# Select the first two dependencies and add to pom.xml

<!-- https://mvnrepository.com/artifact/org.apache.poi/poi -->
<dependency>
    <groupId>org.apache.poi</groupId>
    <artifactId>poi</artifactId>
    <version>5.2.5</version>
</dependency>

<!-- https://mvnrepository.com/artifact/org.apache.poi/poi-ooxml -->
<dependency>
    <groupId>org.apache.poi</groupId>
    <artifactId>poi-ooxml</artifactId>
    <version>5.2.5</version>
</dependency>



# Set up the bugs.xlsx file in resources/bugs

# Open up the file and show


# Add an excel reader to FileUtil.java

import org.apache.poi.ss.usermodel.*;



    public static List<Map<String, Object>> readExcelFromResources(String filePath) {
        List<Map<String, Object>> list = new ArrayList<>();

        try (
                InputStream is = FileUtil.class.getClassLoader().getResourceAsStream(filePath);
                Workbook workbook = WorkbookFactory.create(is)
        ) {

            // Assume data in the first sheet
            Sheet sheet = workbook.getSheetAt(0);
            Iterator<Row> rowIterator = sheet.iterator();

            List<String> headers = new ArrayList<>();
            if (rowIterator.hasNext()) {
                Row headerRow = rowIterator.next();

                // Assuming the first row is the header row
                for (Cell cell : headerRow) {
                    headers.add(cell.getStringCellValue());
                }
            }

            while (rowIterator.hasNext()) {
                Row row = rowIterator.next();
                Map<String, Object> rowData = new HashMap<>();

                for (int cn = 0; cn < row.getLastCellNum(); cn++) {
                    Cell cell = row.getCell(cn, Row.MissingCellPolicy.RETURN_BLANK_AS_NULL);
                    if (cell != null) {
                        rowData.put(headers.get(cn), getCellValue(cell));
                    }
                }
                list.add(rowData);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    private static Object getCellValue(Cell cell) {
        switch (cell.getCellType()) {
            case STRING:
                return cell.getStringCellValue();
            case NUMERIC:
                return cell.getNumericCellValue();
            case BOOLEAN:
                return cell.getBooleanCellValue();
            default:
                return null;
        }
    }


# Go to DataDrivenTests.java and set up the data provider
# Note we print out each bug


    @DataProvider(name = "bugPayloads")
    public Iterator<BugRequestBody> bugPayloads() {
        List<BugRequestBody> bugRequests = new ArrayList<>();
        List<Map<String, Object>> records = FileUtil.readExcelFromResources("bugs/bugs.xlsx");

        for (Map<String, Object> record : records) {
            BugRequestBody bug = BugRequestBody.builder()
                    .createdBy((String) record.get("createdBy"))
                    .priority(((Double) record.get("priority")).intValue())
                    .severity((String) record.get("severity"))
                    .title((String) record.get("title"))
                    .completed((Boolean) record.get("completed"))
                    .build();
            bugRequests.add(bug);

            System.out.println(bug);
        }

        return bugRequests.iterator();
    }


# Comment out the entire test under

void testPOSTRequestToCreateBug(BugRequestBody bug)

# Run the empty test

# Show the contents of the Excel file that we have read in the console output

# DElete the print in the data provider

            System.out.println(bug);


# Now uncomment the contents of the test (no change in the test code)

void testPOSTRequestToCreateBug(BugRequestBody bug)

# Run and show

# Everything should pass


-----------------------------------------------
Use Poiji to read from Excel file - v02
-----------------------------------------------

# Show the bugs.xlsx file once again


# Go to the browser

https://github.com/ozlerhakan/poiji

# Show the Poiji page and what Poiji is used for
# Scroll and show

# Copy over the Maven dependency to pom.xml

<dependency>
  <groupId>com.github.ozlerhakan</groupId>
  <artifactId>poiji</artifactId>
  <version>4.3.0</version>
</dependency>


# Go to

https://mvnrepository.com/

# Search for Poiji and show that this is the latest version


# On IntelliJ 

# Under src/test/org/loonycorn/restassuredtests/model

# Create a new file

BugRequestBodyPoiji.java

# Add this code

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class BugRequestBodyPoiji {
    private String createdBy;
    private Integer priority;
    private String severity;
    private String title;
    private Boolean completed;
}


# To the very first property add the @ExcelCell annotation

# Type it out

@ExcelCell(0)

# Update the code for others as well


    @ExcelCell(1)
    private Integer priority;

    @ExcelCell(2)
    private String severity;

    @ExcelCell(3)
    private String title;

    @ExcelCell(4)
    private Boolean completed;


# Class now looks like this
# The NoArgsConstructor is needed for Poiji to instantiate the class


import com.poiji.annotation.ExcelCell;
import lombok.NoArgsConstructor;
import lombok.Data;

@Data
@NoArgsConstructor
public class BugRequestBodyPoiji {

    @ExcelCell(0)
    private String createdBy;

    @ExcelCell(1)
    private Integer priority;

    @ExcelCell(2)
    private String severity;

    @ExcelCell(3)
    private String title;

    @ExcelCell(4)
    private Boolean completed;
}


# Let's set up a new class under utils/ next to FileUtil

PoijiUtil.java

# this is because this class returns a specific object and is not a general utility

# Add code to this class


import com.poiji.bind.Poiji;
import com.poiji.exception.PoijiExcelType;
import com.poiji.option.PoijiOptions;
import org.loonycorn.restassuredtests.model.BugRequestBodyPoiji;

import java.io.InputStream;
import java.util.List;

public class PoijiUtil {

    public static List<BugRequestBodyPoiji> readExcelFileWithPoiji(String resourcePath) {
        List<BugRequestBodyPoiji> records;

        try (InputStream stream = FileUtil.class.getClassLoader().getResourceAsStream(resourcePath)) {
            PoijiOptions options = PoijiOptions.PoijiOptionsBuilder.settings().build();
            records = Poiji.fromExcel(stream, PoijiExcelType.XLSX, BugRequestBodyPoiji.class, options);
        } catch (Exception e) {
            throw new RuntimeException("Failed to read Excel file", e);
        }

        return records;
    }
}


# In DataDrivenTests.java change the data provider


    @DataProvider(name = "bugPayloads")
    public Iterator<BugRequestBodyPoiji> bugPayloads() {
        List<BugRequestBodyPoiji> bugRequests = PoijiUtil.readExcelFileWithPoiji("bugs/bugs.xlsx");

        bugRequests.forEach(System.out::println);

        return bugRequests.iterator();
    }


# Comment out the test in 

void testPOSTRequestToCreateBug(BugRequestBodyPoiji bug)

# Run the empty test

# Show how the data has been parsed


-----------------------------------------------


# Show this class

BugRequestBodyPoiji

# Note that it uses column numbers to mark the fields

# Open up 

bugs.xlsx

# Now switch the order of the columns in the bugs.xlsx file

# Select the "severity" column

# Right-click -> Cut

# Select the "priority" column

# Right-click -> Insert cut cells

# Now you should have "severity" first and then "priority"


# Run the test code


# Note that in the output you get priority = 0, severity = number

# A better way to set up this mapping of columns is to use the name of the header

# BugRequestBodyPoiji.java


import com.poiji.annotation.ExcelCellName;


    @ExcelCellName("createdBy")
    private String createdBy;

    @ExcelCellName("priority")
    private Integer priority;

    @ExcelCellName("severity")
    private String severity;

    @ExcelCellName("title")
    private String title;

    @ExcelCellName("completed")
    private Boolean completed;


# Back to DataDrivenTests.java 

# Run the empty test and show the output

-----------------------------------------------

# Show how Poiji objects can handle extra columns

# Open bugs.xlsx and add these columns

# team	urgent
# Search	FALSE
# Recommendations	TRUE
# Login	FALSE
# Auth	TRUE
# Marketing	FALSE


# If you run the test now you will see that the objects are created just fine

# But what if you want to access those additional fields and you don't know how many there are?


# Add this to Poiji object

# BugRequestBodyPoiji.java

    @ExcelUnknownCells
    private Map<String, String> additionalFields;


# Run and show the extra fields available now


# Uncomment the test contents

# MAke sure it's signature is updated

void testPOSTRequestToCreateBug(BugRequestBodyPoiji bug)


# Run the tests and show






























































