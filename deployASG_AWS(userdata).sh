#!/bin/bash

# vars
project_name="Geocit134"
repo="https://github.com/mentorchita/Geocit134"

p_ip=`curl https://ipinfo.io/ip`
serv_ip="$p_ip"
DataB_ip="ipDB"

DB_username="usernameDB"
DB_password="passwordDB"

email_adr="email_for_project"
email_password="password_for_email"

# remove old project if exist
sudo rm -rf $project_name

# clone project from github

git clone $repo

# fixing  'pom.xml'

sed -i "s/>servlet-api/>javax.servlet-api/g" ${project_name}/"pom.xml"
sed -i -E "s/(http:\/\/repo.spring)/https:\/\/repo.spring/g" ${project_name}/"pom.xml"
sed -i -E "s/(35.188.29.52)/>${nexus_repo}/g" ${project_name}/"pom.xml"
printf '%s\n' '0?<artifactId>maven-war-plugin<\/artifactId>?a' '                <version>3.3.2</version>' . x | ex ${project_name}/"pom.xml"
sed -i -E ':a;N;$!ba; s/org.hibernate/org.hibernate.validator/2' ${project_name}/"pom.xml"


#  repair favicon.ico
sed -i 's/\/src\/assets/.\/static/g' ${project_name}/src/main/webapp/"index.html"

# repair back-end 
find ./${project_name}/src/main/webapp/static/js/ -type f -exec sed -i "s/localhost/${serv_ip}/g" {} +

# fixing /home/ubuntu/Geocit134/src/main/resources/application.properties 


sed -i -E \
            "s/(front.url=http:\/\/localhost)/front.url=http:\/\/${serv_ip}/g; \
            s/(front-end.url=http:\/\/localhost)/front-end.url=http:\/\/${serv_ip}/g; \

            s/(db.url=jdbc:postgresql:\/\/localhost)/db.url=jdbc:postgresql:\/\/${DataB_ip}/g;
            s/(db.username=postgres)/db.username=${DB_username}/g;
            s/(db.password=postgres)/db.password=${DB_password}/g;

            s/(url=jdbc:postgresql:\/\/35.204.28.238)/url=jdbc:postgresql:\/\/${DataB_ip}/g;
            s/(username=postgres)/username=${DB_username}/g;
            s/(password=postgres)/password=${DB_password}/g;

            s/(referenceUrl=jdbc:postgresql:\/\/35.204.28.238)/referenceUrl=jdbc:postgresql:\/\/${DataB_ip}/g;

            s/(email.username=ssgeocitizen@gmail.com)/email.username=${email_adr}/g;
            s/(email.password=softserve)/email.password=${email_password}/g;" ${project_name}/src/main/resources/application.properties




 # project building
 (cd ${project_name}; /opt/maven/bin/mvn install)

# # project deploying
 sudo cp ${project_name}/target/citizen.war /opt/tomcat/latest/webapps
 sudo systemctl restart tomcat