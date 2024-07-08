package org.loonycorn.restassuredtests.utils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;

import org.apache.poi.ss.usermodel.*;

import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.*;

public class FileUtil {
    private static final ObjectMapper objectMapper = new ObjectMapper();

    public static String readResourceFileAsString(String filePath)
            throws URISyntaxException, IOException {
        // Assuming filePath is relative to the src/test/resources directory
        String path = Objects.requireNonNull(
                FileUtil.class.getClassLoader().getResource(filePath)).toURI().getPath();

        return new String(Files.readAllBytes(Paths.get(path)));
    }

    public static  JsonNode readJsonFileAsJsonNode(String filePath)
            throws URISyntaxException, IOException {
        return objectMapper.readTree(readResourceFileAsString(filePath));
    }

    public static List<List<String>> readCSVFromResources(String filePath) {
        List<List<String>> records = new ArrayList<>();

        try (Reader reader = new InputStreamReader(Objects.requireNonNull(
                FileUtil.class.getClassLoader().getResourceAsStream(filePath)));

            CSVParser csvParser = new CSVParser(reader, CSVFormat.DEFAULT)) {

            for (CSVRecord csvRecord : csvParser) {
                List<String> record = new ArrayList<>();
                for (String field : csvRecord) {
                    record.add(field);
                }
                records.add(record);
            }

        } catch (IOException e) {
            e.printStackTrace();
        }

        return records;
    }


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
}
