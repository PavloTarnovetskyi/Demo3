# Demo 3


# Nexus Sonatype 

### Presettings

In my way, I created a new GCP compute instance with Ubuntu 20.04, 2*CPU and 4GB of ROM. Also, provide Firewall with inbound SSH (22) and Nexus (8081) rules. 


### Installation

There is guide, that i used to install Nexus on Linux Ubuntu-> [kifarunix](https://kifarunix.com/install-nexus-repository-manager-on-ubuntu/)

  
### Configuring

For Geo Citizen there are already default *maven-shapshot* and *maven-release* repositories.  


# Jenkins + Maven

## Maven

Jenkins Maven Configuration -> [toolsqa](https://www.toolsqa.com/jenkins/jenkins-maven/#:~:text=Jenkins-,Maven,management%20and%20creating%20automated%20builds.)


## Maven + Nexus (deploy by pom.xml)

To deploy artefacts (*.war* files in case of Geo Citizen) automatically by *Maven*  in *pom.xml* in "distributionManagement" block we need to attached url with our nexus repository:

  ```xml
  
  <distributionManagement>
    <repository>
      <id>nexus</id>
      <name>Releases</name>
      <url>http://35.205.84.87:8081/repository/maven-releases</url>
    </repository>
    <snapshotRepository>
      <id>nexus</id>
      <name>Snapshot</name>
      <url>http://35.205.84.87:8081/repository/maven-snapshots</url>
    </snapshotRepository>
  </distributionManagement>
      
  ```

 *Maven* needs credentials to *Nexus* storage for *release* and *snapshot* reposotories (creds of user were created in previous chapter). This credentials must be written in *settings.xml* .
```

<server>
      <id>nexus</id>
      <username>>(username_in_your_nexus_repo)</username>
      <password>(password_to_your_user_nexus_repo)</password>
    </server>
```


Also in *pom.xml* must be header with neccesary inforamtion about app:

  ```xml
  <modelVersion>4.0.0</modelVersion>
	
  <groupId>com.softserveinc</groupId>
	<artifactId>geo-citizen</artifactId>
  <version>1.0.5-SNAPSHOT</version>
  
  <packaging>war</packaging>
  ```

**TIP**: if there is *SNAPSHOT*-word in `<version>` - artefact will be deployed to *snapshot* type of repository on Nexus storage, OTHERWISE (if *SNAPSHOT* is missed) - to *release* type of repo.



# AWS Auto Scaling Group & Load Balancing



AWS - Elastic Load Balancer -> [youtube](https://www.youtube.com/watch?v=BEFTuCjtPd8&list=PLg5SS_4L6LYsxrZ_4xE_U95AtGsIB96k9&index=24)

AWS - Auto Scaling Group -> [youtube](https://www.youtube.com/watch?v=CG4PwqKKVaM&list=PLg5SS_4L6LYsxrZ_4xE_U95AtGsIB96k9&index=25)
 

# Docker

### Manually

Basic guide about containerisation -> [linuxhint](https://linuxhint.com/create_docker_image_from_scratch/)

Firstly get base docker image *tomcat*.

**TIP**: tomcat image must be 9 version !!! 

Then create *Dockerfile*:

  ```dockerfile
  FROM tomcat:9

ADD citizen.war /usr/local/tomcat/webapps/

EXPOSE 8080
CMD ["catalina.sh", "run"]

  ```

Now you can execute next Docker commands:

  ```bash
  # build docker image from Dockerfile
  ~ docker build . -t <ip-nexus-repo:port>/citizen -f /path/to/Dockerfile
  ```

Then create *DockerfileDB* for DB

``` dockerfile
FROM postgres:alpine

ENV POSTGRES_USER="name"
ENV POSTGRES_PASSWORD="password"
ENV POSTGRES_DB=ss_demo_1

EXPOSE 5432
```
Now you can execute next Docker commands:

  ```bash
  # build docker image from Dockerfile
  ~ docker build . -t <ip-nexus-repo:port>/postgresgeo:alpine -f /path/to/DockerfileDB
  ```

  ## Create docker-compose.yaml
  ``` bash
version: "3.9"
services:
  geocit_db:
    image: <ip-nexus-repo:port>/postgresgeo:alpine
    restart: always
    ports:
      - "5432:5432"
    volumes:
      - ./pg_data:/var/lib/postgresql/data


  citizen:
    image: <ip-nexus-repo:port>/citizen
    restart: always
    ports:
      - "8080:8080"

  ```

## Run docker-compose.yaml
``` bash
~ docker-compose up -d
```
## Configure Nexus 3 as private Docker Registry

Configurations your`s nexus repo for docker ->[coachdevops.com](https://www.coachdevops.com/2020/08/how-to-configure-nexus-3-as-docker.html).  


## Install Docker Compose ->[docs.docker.com](https://docs.docker.com/compose/install/)

## Docker login to Nexus repo -> [docs.docker.com](https://docs.docker.com/engine/reference/commandline/login/)

```bash
docker login -u <username> -p <password> <repo>
```

## Deploy a plain HTTP registry
Warning: It’s not possible to use an insecure registry with basic authentication.

This procedure configures Docker to entirely disregard security for your registry. This is very insecure and is not recommended. It exposes your registry to trivial man-in-the-middle (MITM) attacks. Only use this solution for isolated testing or in a tightly controlled, air-gapped environment.

Edit the *daemon.json* file, whose default location is /etc/docker/daemon.json on Linux. 

If the daemon.json file does not exist, create it. Assuming there are no other settings in the file, it should have the following contents:
```
{
  "insecure-registries" : ["<nexus-repo-ip>:port"]
}

```
### Push images to nexus repo:
  ```bash
  # push docker image with citizen app to  nexus repo
  ~ docker push <ip-nexus-repo:port>/citizen
   # push docker image with DB to  nexus repo
  ~ docker push <ip-nexus-repo:port>/postgresgeo:alpine
  ```

# Grafana

Main guide to installing *Grafana* (Enterprise edition) on Debian or Ubuntu-> [grafana](https://grafana.com/docs/grafana/latest/installation/debian/)

# Prometheus

How to Install Prometheus on Ubuntu 20.04 -> [linoxide](https://linoxide.com/how-to-install-prometheus-on-ubuntu/)

How To Monitor Linux Servers Using Prometheus Node Exporter -> [devopscube](https://devopscube.com/monitor-linux-servers-prometheus-node-exporter/)

Dashboard for Prometheus node_exporter -> [grafana](https://grafana.com/grafana/dashboards/1860)

# Grafana + Prometheus

Guide for establishing connection *Grafana* with *Prometheus* -> [linuxhint](https://linuxhint.com/connect-grafana-with-prometheus/)

# SensuGO

How to install Sensu Go Monitoring Tool on Ubuntu 20.04 -> [help.clouding.io](https://help.clouding.io/hc/en-us/articles/360020996659-How-to-install-Sensu-Go-Monitoring-Tool-on-Ubuntu-20-04/)  

Installation of *SensuGO* was made on instance with *Docker, Prometheus, Grafana ...*, so default config file 'backend.yaml' of *SensuGo* must be changed due to ports conflicts:

  ```md
  # change all configs to these ports

  - api-listen-address: "[::]:8090" 
  - api-url: "http://localhost:8090"
  - agent-port: 8091
  - dashboard-port: 3010
  ```

Visit *SensuGo* on http://ip:dashboard-port, input login/pass from *sensu-backend init* command. Also you can check *SensuGO* healthby:

  ```bash
  # default port is 8080 but in our case 8090
  ~ curl http://127.0.0.1:8090/health
  ```



Install *sensu-go-agent*  :

  ```bash
  # installation
  ~ sudo apt-get install sensu-go-agent -y

  # get deafault config  file (like for sensu-go-backend)
  ~ sudo curl -L https://docs.sensu.io/sensu-go/latest/files/agent.yml -o /etc/sensu/agent.yml
  ```

Due to changes in 'backend.yml' for sensu backend we have to change 'agent.yml' also:

  ```md
  # uncomment this !
  - backend-url:
  # change this as 'agent-port' in backend.yml
  - "ws://127.0.0.1:8091"
  ```

Start sertvice unit of *sensu-agent* as well:

  ```bash
  ~ sudo systemctl enable --now sensu-agent
  ```

Check status of *sensu-agent* service. 

**TIP**: if *sensu-agent* service failed to start:

  - check ports in configs files (backend.yml and agent.yml) - if you changed them of course ...
  - check owner (must be 'sensu' user, he was created automatically) of folder and content for:
    - backend - /var/cache/sensu/sensu-backend/
    - agent - /var/cache/sensu/sensu-agent/

... then try to restart unit and check again.

When all services are installed (backend+WEB, cli, agent), visit web console again and check some info:

  - Main menu - Dasboard
  - Main menu - Select name - select 'default' (as setted in backend configs) - Entitites - select 'your entity name (hostname + OS name)' - select 'keepalive'


## On the workstation

Now that we have sensu backend running, let's install `sensuctl` on the local workstation.
Sensuctl is a cli tool used to manage Sensu

To install it on Linux machine:

```
# Add the Sensu repository
curl -s https://packagecloud.io/install/repositories/sensu/stable/script.deb.sh | sudo bash

# Install the sensu-go-cli package
sudo apt-get install sensu-go-cli
```
Follow instructions [HERE](https://docs.sensu.io/sensu-go/latest/operations/deploy-sensu/install-sensu/#install-sensuctl) to install
sensuctl for other operating systems (your local machine)


To start using sensuctl, we need to configure it with the username, password and the
address to reach our sensu backend api


From your local machine (not the sensu-backend server)
```
sensuctl configure -n \
--username 'admin' \
--password 'password' \
--namespace default \
--url 'http://ip:8090'
```

Run `sensuctl config view` and it should show something like

```
❯ sensuctl config view
=== Active Configuration
API URL:                  http://ip:8090
Namespace:                default
Format:                   tabular
Timeout:                  15s
Username:                 admin
JWT Expiration Timestamp: 1620564854
```

That means sensuctl is all good to go. With these steps, sensuctl has written the authentication details into 
```
~/.config/sensu/sensuctl/profile

and

~/.config/sensu/sensuctl/cluster
```
# Grafana + SensuGO

Main installation guide -> [sensu](https://sensu.io/blog/visualizing-sensu-go-data-in-grafana):

  - check the latest release here -> [github](https://github.com/sensu/grafana-sensu-go-datasource/)

**TIP**: due to old state of this plugin, *Grafana* won't load this plugin - 'sens-sensugo-datasource' isn't signed !
  - after installation find conf file of *Grafana* 'default.ini' (in this case /usr/share/grafana/conf/defaults.ini)
  - change the key 'allow_loading_unsigned_plugins'

    ```ini
    # append name of installed SensuGO plugin to =
    allow_loading_unsigned_plugins = sensu-sensugo-datasource
    ```

  - restart *Grafana* unit

  - check list of 'data sources' on *Grafana* dashboard, there must appear 'Sensu Go' with *unsigned* label (in my case in the bottom of the list)

... info about this and the other keys in 'default.ini' -> [grafana](https://grafana.com/docs/grafana/latest/administration/configuration/#allow_loading_unsigned_plugins)



  - some sample dashboards use old version of 'pie-chart' -> [grafana](https://grafana.com/grafana/plugins/grafana-piechart-panel/?tab=installation)
  - this chart can be installed from Grafana - Configuration - Plugins - search 'pie' - one chart is already installed (new), choose the other (old) and install

