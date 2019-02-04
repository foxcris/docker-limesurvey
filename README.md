# docker-limesurvey installation


A simple apache installation with all required modules to run kimai. Let's encrypt can be used to optain a valid certificate. 
  
## Configuration
 
### Volume Configuration
 | PATH in container | Description |
 | ---------------------- | ----------- |
 | /var/log/apache2 | Logging directory |
 | /etc/letsencrypt | Storage of the created let's encrypt certificates. If this directory is empty on start a default configuration is provided.|
 | /var/www/html/appplication/config | Configuration directroy for limesurvey |
 | /var/www/html/tmp | Temporary directory. write permissione required. |
 | /var/www/html/upload | Upload directroy. Wirte permission required. |
 
### Letsencrypt
 | Environment Variable | Description |
 | ---------------------- | ----------- |
 | LETSENCRYPTDOMAINS | Comma seperated list of all domainnames to request/renew a let's encrypt certificate |
 | LETSENCRYPTEMAIL | E-Mail to be used for notifications from let's encrypt |

### Database
For a database you can use the standard mariadb docker container and connect it via a docker network.
