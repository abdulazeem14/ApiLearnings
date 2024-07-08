package org.loonycorn.bugsapi.utils;
import org.loonycorn.bugsapi.model.Bug;

import java.util.ArrayList;
import java.util.List;

public class BugUtil {

    public static List<Bug> createBugs() {
        List<Bug> bugs = new ArrayList<>();

        String[] firstNames = {"John", "Jane", "Mike", "Sarah", "Alex"};
        String[] lastNames = {"Smith", "Johnson", "Williams", "Brown", "Jones"};
        String[] users = new String[firstNames.length * lastNames.length];
        int userIndex = 0;
        for (String firstName : firstNames) {
            for (String lastName : lastNames) {
                users[userIndex++] = firstName + " " + lastName;
            }
        }

        String[] severities = {"low", "medium", "high", "critical"};

        Boolean[] completedStatus = {true, false};

        String[] titles = {
                "Login page not responsive - and is also slow",
                "User profile update fails shows timeout",
                "Data sync error on mobile page, timeout",
                "Payment gateway timeout",
                "Search functionality broken",
                "Email notifications delayed, slow",
                "High memory usage on new feature",
                "Incorrect error messages - broken",
                "File upload size limit incorrect, broken",
                "API response time slow"
        };

        for (int i = 0; i < 25; i++) {
            String createdBy = users[i % users.length];

            // This will cycle through 0-3
            Integer priority = i % 4;

            // This will cycle through the severities
            String severity = severities[i % 4];
            String title = titles[i % titles.length];

            // This alternates between true and false
            Boolean completed = completedStatus[i % 2];

            Bug bug = new Bug(createdBy, priority, severity, title, completed);
            bugs.add(bug);
        }

        return bugs;
    }
}
