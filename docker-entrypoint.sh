#!/bin/bash

if [ `ls /etc/apache2/sites-available/ | wc -l` -eq 0 ]
then
  cp -r /etc/apache2/sites-available_default/* /etc/apache2/sites-available/
fi

if [ `ls /etc/letsencrypt/ | wc -l` -eq 0 ]
then
  cp -r /etc/letsencrypt_default/* /etc/letsencrypt/
fi

if [ `ls /var/www/html/upload/ | wc -l` -eq 0 ]
then
  cp -r /var/www/html/upload_default/* /var/www/html/upload/
fi

find /var/www/html/application/config ! -name 'config.php' -type f -exec rm -f {} +
cp -r /var/www/html/application/config_default/* /var/www/html/application/config
chown -R www-data:www-data /var/www/html
chmod -R o-w-r-x /var/www/html/
chmod -R -w /var/www/html
chmod -R 770 /var/www/html/appliction/config
chmod -R 770 /var/www/html/tmp
chmod -R 770 /var/www/html/upload

#Perform Databaseupdate
php /var/www/html/application/commands/console.php updatedb

#List site and enable
ls /etc/apache2/sites-available/ -1A | a2ensite *.conf

#LETSECNRYPT
if [ "$LETSENCRYPTDOMAINS" != "" ]
then
  /usr/sbin/apache2ctl start
  domains=$(echo $LETSENCRYPTDOMAINS | tr "," "\n")
  for domain in $domains
  do
    certbot --apache -n -d $domain --agree-tos --email $LETSENCRYPTEMAIL
  done
  /usr/sbin/apache2ctl stop
fi

#Start Cron
/etc/init.d/anacron start
/etc/init.d/cron start

#Launch Apache on Foreground
/usr/sbin/apache2ctl -D FOREGROUND
