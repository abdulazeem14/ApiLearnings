#################################
Installing Jenkins
#################################

=> In browser navigate to https://www.jenkins.io

=> Scroll and show what Jenkins is all about

=> Click on "Download"

=> Click on MacOS and see how to install

=> Click on Windows (it will download an MSI installer to install)

#################################

# Need to show install on Windows as well


#################################

# Permanent Installation
=> Open terminal and run the following commands to install Jenkins

$ brew --version

$ java -version

$ brew install jenkins-lts

$ brew services info jenkins-lts

$ brew services start jenkins-lts

$ brew services info jenkins-lts

# Should be running


# => Open browser and navigate to http://localhost:8080

# (In terminal)

$ cat /Users/loonycorn/.jenkins/secrets/initialAdminPassword

=> Copy the password and paste it in the Jenkins setup page

=> Click on "Install suggested plugins"

username: loonycorn
password: password
confirm password: password
fullname: Loonycorn
email: cloud.user@loonycorn.com

=> Click on "Save and Continue"

=> Click on "Save and Finish"

=> Click on "Start using Jenkins"





