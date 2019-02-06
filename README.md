# docker-limesurvey installation


A simple apache installation with all required modules to run kimai. Let's encrypt can be used to optain a valid certificate. 
  
## Configuration
 
### Configuration files, log files, buisness data
The following directories can be loaded from the host to keep the data and configuration files out of the container:

 | PATH in container | Description |
 | ---------------------- | ----------- |
 | /var/log/apache2 | Logging directory |
 | /etc/letsencrypt | Storage of the created let's encrypt certificates. If this directory is empty on start a default configuration is provided.|
 | /var/www/html/appplication/config | Configuration directroy for limesurvey |
 | /var/www/html/tmp | Temporary directory. |
 | /var/www/html/upload | Upload directroy. |
 
### Environment variables
The following environment variables are available to configure the container on startup.

 | Environment Variable | Description |
 | ---------------------- | ----------- |
 | LETSENCRYPTDOMAINS | Comma seperated list of all domainnames to request/renew a let's encrypt certificate |
 | LETSENCRYPTEMAIL | E-Mail to be used for notifications from let's encrypt |

## Container Tags

 | Tag name | Description |
 | ---------------------- | ----------- |
 | latest | Latest stable version of the container |
 | stable | Latest stable version of the container |
 | dev | latest development version of the container. Do not use in production environments! |

## Usage

To run the container and store the data and configuration on the local host run the following commands:
1. Create storage directroy for the configuration files, log files and data. Also create a directroy to store the necessary script to create the docker container and replace it (if not using eg. watchtower)
```
mkdir /srv/docker/limesurvey
mkdir /srv/docker-config/limesurvey
```

3. Create an file to store the configuration of the environment variables
```
touch /srv/docker-config/limesurvey/env_file
```
```
#Comma seperated list of domainnames
LETSENCRYPTDOMAINS=limesurvey.example.com
LETSENCRYPTEMAIL=example@example.com
```

3. Create the docker container and configure the docker networks for the container. I always create a script for that and store it under
```
touch /srv/docker-config/limesurvey/create.sh
```
Content of create.sh:
```
#!/bin/bash

docker pull foxcris/docker-limesurvey
docker create\
 --restart always\
 --name limesurvey\
 -v /srv/docker/limesurvey/var/log/apache2:/var/log/apache2\
 -v /srv/docker/limesurvey/var/log/letsencrypt:/var/log/letsencrypt\
 -v /srv/docker/limesurvey/etc/letsencrypt:/etc/letsencrypt\
 -v /srv/docker/limesurvey/var/www/html/upload:/var/www/html/upload\
 -v /srv/docker/limesurvey/var/www/html/application/config:/var/www/html/application/config\
 --env-file ./env_file\
 --name limesurvey\
 foxcris/docker-limesurvey
docker network connect database limesurvey
```

4. Create replace.sh to install/update the container. Store it in
```
touch /srv/docker-config/limesurvey/replace.sh
```
```
#/bin/bash
docker stop limesurvey
docker rm limesurvey
./create.sh
docker start limesurvey
```


### Database
For a database you can use the standard mariadb docker container and connect it via a docker network.

