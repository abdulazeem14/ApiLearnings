package org.loonycorn.bugsapi.controller;

import org.loonycorn.bugsapi.model.Bug;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;

import java.util.*;
import java.time.LocalDateTime;
import java.util.stream.Collectors;

@RestController
public class BugController {
    private final List<Bug> bugs = new ArrayList<>();

    @GetMapping("/")
    public String welcome() {
        return "Welcome to the Bug Tracking API!";
    }

    @GetMapping("/bugs")
    public ResponseEntity<List<Bug>> getBugs(
            @RequestParam(required = false) String createdByContains,
            @RequestParam(required = false) Integer priority,
            @RequestParam(required = false) String severity,
            @RequestParam(required = false) Boolean completed,
            @RequestParam(required = false) String titleContains
    ) {

        List<Bug> filteredBugs = bugs.stream()
                .filter(bug -> createdByContains == null || bug.getCreatedBy().contains(createdByContains))
                .filter(bug -> priority == null || bug.getPriority().equals(priority))
                .filter(bug -> severity == null || bug.getSeverity().equals(severity))
                .filter(bug -> completed == null || bug.getCompleted().equals(completed))
                .filter(bug -> titleContains == null || bug.getTitle().contains(titleContains))
                .collect(Collectors.toList());

        return ResponseEntity.ok(filteredBugs);
    }

    @GetMapping("/bugs/{bugId}")
    public ResponseEntity<?> getBug(@PathVariable String bugId) {

        Bug bug = bugs.stream()
                .filter(b -> b.getBugId().equals(bugId))
                .findFirst()
                .orElse(null);

        if (bug != null) {
            return ResponseEntity.ok(bug);
        } else {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(Collections.singletonMap("error", "Bug not found"));
        }
    }

    @PostMapping("/bugs")
    public ResponseEntity<?> createBug(@RequestBody Bug bug) {
        bugs.add(bug);

        return ResponseEntity.status(HttpStatus.CREATED).body(bug);
    }

    @PutMapping("/bugs/{bugId}")
    public ResponseEntity<?> updateBug(@PathVariable String bugId, @RequestBody Bug updatedBug) {

        Bug bugToUpdate = bugs.stream()
                .filter(b -> b.getBugId().equals(bugId))
                .findFirst()
                .orElse(null);

        if (bugToUpdate != null) {
            bugToUpdate.setCreatedBy(updatedBug.getCreatedBy());
            bugToUpdate.setPriority(updatedBug.getPriority());
            bugToUpdate.setSeverity(updatedBug.getSeverity());
            bugToUpdate.setTitle(updatedBug.getTitle());
            bugToUpdate.setCompleted(updatedBug.getCompleted());
            bugToUpdate.setUpdatedOn(LocalDateTime.now());

            return ResponseEntity.ok(bugToUpdate);
        } else {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(Collections.singletonMap("error", "Bug not found"));
        }
    }

    @PatchMapping("/bugs/{bugId}")
    public ResponseEntity<?> patchBug(@PathVariable String bugId, @RequestBody Bug updatedBug) {
        Bug bugToUpdate = bugs.stream()
                .filter(b -> b.getBugId().equals(bugId))
                .findFirst()
                .orElse(null);

        if (bugToUpdate != null) {
            if (updatedBug.getCreatedBy() != null) {
                bugToUpdate.setCreatedBy(updatedBug.getCreatedBy());
            }
            if (updatedBug.getPriority() != null) {
                bugToUpdate.setPriority(updatedBug.getPriority());
            }
            if (updatedBug.getSeverity() != null) {
                bugToUpdate.setSeverity(updatedBug.getSeverity());
            }
            if (updatedBug.getTitle() != null) {
                bugToUpdate.setTitle(updatedBug.getTitle());
            }
            if (updatedBug.getCompleted() != null) {
                bugToUpdate.setCompleted(updatedBug.getCompleted());
            }
            bugToUpdate.setUpdatedOn(LocalDateTime.now());

            return ResponseEntity.ok(bugToUpdate);
        } else {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(Collections.singletonMap("error", "Bug not found"));
        }
    }

    @DeleteMapping("/bugs/{bugId}")
    public ResponseEntity<?> deleteBug(@PathVariable String bugId) {
        Bug bug = bugs.stream()
                .filter(b -> b.getBugId().equals(bugId))
                .findFirst()
                .orElse(null);

        if (bug != null) {
            bugs.remove(bug);

            Map<String, String> responseMessage = new HashMap<>();
            responseMessage.put("message", "Bug deleted");
            responseMessage.put("bug_id", bugId);

            return ResponseEntity.ok(responseMessage);
        } else {
            return ResponseEntity
                    .status(HttpStatus.NOT_FOUND)
                    .body(Collections.singletonMap("error", "Bug not found"));
        }
    }
}
