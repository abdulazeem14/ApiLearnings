#################################
Email Notification
#################################

# (Make sure 2 factor authentication is enabled)
# Start from the mail gmail page

=> Click on the top right

=> Account -> Security -> 2-step verification > App passwords

app name: githubactions-notification

> Click Generate
# ojos husa luul qtpq

################################# (V4)

=> Open "bugs-api-tests-workflow.yml" file
# Replace with the below code

name: Java CI with Maven for Bug API tests

on:
  push:
    branches: [ "master" ]

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: maven
    - name: Test Execution
      run: mvn -B -f pom.xml clean test
    - name: Get List of Files
      run: ls -a
    - name: What is in the target folder
      run: ls -a target
    - name: SureFire Reports
      uses: actions/upload-artifact@v2
      with:
        name: test-results
        path: target/surefire-reports
      - name: Send Email
        uses: dawidd6/action-send-mail@v3
        with:
          server_address: smtp.gmail.com
          server_port: 465
          secure: true
          username: loony.test.001@gmail.com
          password: ojoshusaluulqtpq
          subject: Github Actions job result
          to: cloud.user@loonycorn.com
          from: Loonycorn
          body: All the tests for ${{github.repository}} are completed!
          attachments: target/surefire-reports/emailable-report.html

#################################

=> Click "Commit changes"

=> Click on "Actions" from the top navbar

=> Click on the recent workflow run -> "build"

=> Expand all the steps and observe the logs

=> Go to the email and check the email and open the attachment


#################################

# It is never a good idea to write all our sensitive data in open, as it is a public repo
# it is better to use enviroments to represent sensitive data


=> Click on "Settings" > "Secrets and variables" > "Actions"

> Click "New repo secret"

name: EMAIL_SERVER_ADDRESS
value: smtp.gmail.com

name: EMAIL_SERVER_PORT
value: 465

name: EMAIL_ADDRESS
value: loony.test.001@gmail.com

name: EMAIL_PASSWORD
value: ojoshusaluulqtpq


=> Paste the below code in the "bugs-api-tests-workflow.yml" file

- name: Send Email
  uses: dawidd6/action-send-mail@v3
  with:
    server_address: ${{ secrets.EMAIL_SERVER_ADDRESS }}
    server_port: ${{ secrets.EMAIL_SERVER_PORT }}
    secure: true
    username: ${{ secrets.EMAIL_ADDRESS }}
    password: ${{ secrets.EMAIL_PASSWORD }}
    subject: Github Actions job result
    to: cloud.user@loonycorn.com
    from: Loonycorn
    body: All the tests for ${{github.repository}} are completed!
    attachments: target/surefire-reports/emailable-report.html

#################################

=> Click "Commit changes"

=> Click on "Actions" from the top navbar

=> Click on the recent workflow run -> "build"

=> Expand all the steps and observe the logs

=> Go to the email and check the email and open the attachment




