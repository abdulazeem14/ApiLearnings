package org.loonycorn.bugsapi.model;

import java.util.UUID;
import java.time.LocalDateTime;

public class Bug {
    private String bugId;
    private String createdBy;
    private LocalDateTime createdOn;
    private LocalDateTime updatedOn;
    private Integer priority;
    private String severity;
    private String title;
    private Boolean completed;

    public Bug(String createdBy, Integer priority, String severity, String title, Boolean completed) {
        this.bugId = UUID.randomUUID().toString();
        this.createdBy = createdBy;
        this.createdOn = LocalDateTime.now();
        this.updatedOn = this.createdOn;
        this.priority = priority;
        this.severity = severity;
        this.title = title;
        this.completed = completed;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public void setPriority(Integer priority) {
        this.priority = priority;
    }

    public void setSeverity(String severity) {
        this.severity = severity;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setCompleted(Boolean completed) {
        this.completed = completed;
    }

    public void setUpdatedOn(LocalDateTime updatedOn) {
        this.updatedOn = updatedOn;
    }

    public String getBugId() {
        return bugId;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public LocalDateTime getCreatedOn() {
        return createdOn;
    }

    public LocalDateTime getUpdatedOn() {
        return updatedOn;
    }

    public Integer getPriority() {
        return priority;
    }

    public String getSeverity() {
        return severity;
    }

    public String getTitle() {
        return title;
    }

    public Boolean getCompleted() {
        return completed;
    }
}
