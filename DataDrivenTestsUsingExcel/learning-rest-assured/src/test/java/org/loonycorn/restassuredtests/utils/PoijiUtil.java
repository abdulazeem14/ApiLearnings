package org.loonycorn.restassuredtests.utils;

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
