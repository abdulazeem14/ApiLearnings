package org.loonycorn.restassuredtests.model;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class BugRequestBody {
    private String createdBy;
    private Integer priority;
    private String severity;
    private String title;
    private Boolean completed;
}
