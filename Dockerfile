FROM debian:buster

MAINTAINER foxcris

#repositories richtig einrichten
RUN echo 'deb http://deb.debian.org/debian buster main' > /etc/apt/sources.list
RUN echo 'deb http://deb.debian.org/debian buster-updates main' >> /etc/apt/sources.list
RUN echo 'deb http://security.debian.org buster/updates main' >> /etc/apt/sources.list
#backports fuer certbot
RUN echo 'deb http://ftp.debian.org/debian buster-backports main' >> /etc/apt/sources.list

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales && apt-get clean
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF8
#automatische aktualiserung installieren + basic tools
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get install -y nano less wget anacron unattended-upgrades apt-transport-https htop curl unzip && apt-get clean

#apache
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get install -y apache2 libapache2-mod-php7.3 php-mysql php-xml php-mbstring php-gd php-ldap php-zip php-imap php-curl && apt-get clean

#certbot
RUN apt-get update && apt-get -y upgrade && DEBIAN_FRONTEND=noninteractive apt-get install -y python-certbot-apache -t buster-backports && apt-get clean

ARG LIMESURVEY_VERSION=4.3.3
ARG LIMESURVEY_URL=https://download.limesurvey.org/latest-stable-release/limesurvey4.3.3+201228.zip
ARG LIMESURVEY_SHA256=e4cacde9d5d1814a75ce0b913f7c6db4df97aea7f2a1d9af3adb814ac662ae8a 

RUN curl -L -o limesurvey.zip ${LIMESURVEY_URL}\
  && echo "${LIMESURVEY_SHA256} limesurvey.zip" | sha256sum -c \
  && mkdir -p /var/www/html \
  && unzip limesurvey.zip -d /var/www/html/ \
  && mv /var/www/html/limesurvey/* /var/www/html/ \
  && rm -r /var/www/html/limesurvey \
  && chown -R www-data:www-data /var/www/html/ \
  && rm *.zip

RUN mv /var/www/html/application/config /var/www/html/application/config_default
RUN mv /var/www/html/upload /var/www/html/upload_default
RUN mv /etc/letsencrypt/ /etc/letsencrypt_default

RUN rm /var/www/html/index.html

VOLUME /etc/apache2/sites-available
VOLUME /var/log/apache2
VOLUME /var/log/letsencrypt
VOLUME /etc/letsencrypt
VOLUME /var/www/html/upload
VOLUME /var/www/html/application/config

EXPOSE 80 443
COPY docker-entrypoint.sh /
RUN chmod 755 /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]
