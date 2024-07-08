package org.loonycorn.restassuredtests.model;

import com.poiji.annotation.ExcelCell;
import com.poiji.annotation.ExcelCellName;
import com.poiji.annotation.ExcelUnknownCells;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

@Data
@NoArgsConstructor
public class BugRequestBodyPoiji {

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

    @ExcelUnknownCells
    private Map<String, String> additionalFields;
}
