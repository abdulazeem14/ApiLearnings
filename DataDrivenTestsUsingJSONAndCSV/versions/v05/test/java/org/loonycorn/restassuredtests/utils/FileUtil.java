package org.loonycorn.restassuredtests.utils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;

import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

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

}
