package org.loonycorn.restassuredtests.utils;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Paths;
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

}
