
#!/bin/bash

exec > /var/log/sonar.log 2>&1
set -xe
sudo apt update -y
sudo docker run -d --name sonar -p 9000:9000 sonarqube:lts-community