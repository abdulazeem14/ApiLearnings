package org.loonycorn.restassuredtests.model;

import lombok.Data;

@Data
public class BugRequestBody {
    private String createdBy;
    private Integer priority;
    private String severity;
    private String title;
    private Boolean completed;
}
