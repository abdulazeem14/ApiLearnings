#################################
Email Notification
#################################

# (Make sure 2 factor authentication is enabled)
# Start from the mail gmail page

=> Click on the top right

=> Account -> Security -> 2-step verification > App passwords

app name: jenkins-notification

> Click Generate
# ojos husa luul qtpq

#################################

# In Jenkins dashboard
=> Click "Manage Jenkins" from the left pane

=> "System" -> "E-mail Notification"

SMTP server: smtp.gmail.com

=> Click "Advanced"

[TICK] Use SMTP Authentication
Username: loony.test.001@gmail.com
Password: ojoshusaluulqtpq

[TICK] Use SSL

SMTP Port: 465

[TICK] Test configuration by sending test e-mail
Test e-mail recipient: cloud.user@loonycorn.com

=> Click "Test configuration"

=> Goto "cloud.user@loonycorn.com" email and verify the email has been received

=> Click "Apply" -> "Save"

#################################

# In Jenkins dashboard
=> Click "Manage Jenkins" from the left pane

=> Click "Credentials" -> "System" -> "Global credentials"

=> Click "Add Credentials"

Kind: Username with password
Scope: Global
Username: loony.test.001@gmail.com
Password: ojoshusaluulqtpq
ID: loony-test-001

=> Click "Create"


#################################
=> Go back to the dashboard

=> Click "Manage Jenkins" from the left pane

=> Click "System"

=> Scroll down to "Extended E-mail Notification"

SMTP server: smtp.gmail.com
SMTP port: 465

=> Click "Advanced"

Credentials: loony-test-001@gmail.com/********

[TICK] Use SSL

Default Content Type: HTML (text/html)

Default Recipients: cloud.user@loonycorn.com

(Paste the below content in the "Default Content" section)
Default Content:
<h1>Welcome to Jenkins</h1>
<h4>Here are the details of the build</h4>

$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS:

Check console output at $BUILD_URL to view the results.

<h4>Thank you</h4>

=> Click "Default Trigger"
[TICK] Always

=> Click "Apply" -> "Save"

#################################

=> Click on "BugsApiTestsMaven" -> "Configure"

=> Click "Post-build Actions"

[TICK] "Editable Email Notification"

(We can override the default settings here, but we will use the default settings)

=> Click "Advance Settings"

=> Scroll to Trigger
# Remove "Developers"

=> Click "Apply" -> "Save"

=> Click "Build Now"
(See the build console)

=> Goto "cloud.user@loonycorn.com" and check the email




