#!/bin/bash
#
#Parms info 
# $1 -domain name 
# $2 - Folder name && DatabaseName
# $3 - magento user name
# $4 - magento user password
# $5 - magento SQL Password
# $6 - magento admin first name
# $7 -magento admin last name
# $8 -magneto admin email
# $9 - magento admin usrname
#$10 - magento admin pwd
#$11 - magento connect public key
#$12 -magento connect private key
#$12 -HOSTNAME
#steps to install apache2

set -x
#set -xeuo pipefail to check if root user 

if [[ $(id -u) -ne 0 ]] ; then
    echo "Must be run as root"
    exit 1
fi

if [ $# < 13 ]; then
     echo ""
        echo "Missing parameters.";
        echo "1st parameter is domain name";
        echo "2nd parameter is magento folder name in which magento will installed";
        echo "3rd parameter is magento linux user (it will create it)";
        echo "4th parameter is magento linux password (it will create it)";
		echo "5th parameter is  mysql SQL Password";
		echo "6th parameter is magento admin first name";
		echo "7th parameter is magento admin last name";
		echo "8th parameter is admin email";
		echo "9th parameter is magento admin usrname";
		echo "10th parameter is magento admin pwd";
		echo "11th parameter is magento connect public key";
		echo "12th parameter is magento connect private key";
		echo "13th parameter is HOSTNAME";
        #echo "Try this: magento-prepare.sh 2.0.7 mywebshop.com magento magento";
        echo "";
    exit 1
fi

#Installbasic
   apt-get install \
    git \
    curl \
    unzip \
    --yes

#Install Apache
 apt-get -y install apache2

#install MYSQL 
 debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password password $5"
 debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password_again password $5"
 apt-get -y install mysql-server-5.7 mysql-client-5.7
# apt-get install mysql-server-5.6 --yes
mysql -u root --password="$5" -e"DELETE FROM mysql.user WHERE User=''; DROP DATABASE IF EXISTS test; CREATE DATABASE IF NOT EXISTS $2; FLUSH PRIVILEGES; SHOW DATABASES;"

# Update apt-get 
apt-get update

#Install PHP
 apt-get install \
    php-fpm \
    php-mysql \
    php-mcrypt \
    php-curl \
    php-cli \
    php-gd \
    php7.0-xsl \
    php-json \
    php-intl \
    php-pear \
    php-dev \
    php-common \
    php-soap \
    php-mbstring \
    php-zip \
    --yes

 service php7.0-fpm restart
 apt-get -y install apache2 php7.0 libapache2-mod-php7.0
  service apache2 restart

#download composer and set
curl -sS https://getcomposer.org/installer |  php
 mv composer.phar /usr/local/bin/composer

 # Create a new user for magento
 adduser $3 --gecos "Magento System,0,0,0" --disabled-password
echo "$3:$4" |  chpasswd
 usermod -g www-data $3

#set rep.magento.com authendication options in order to get the details
 composer config -g http-basic.repo.magento.com ${11} ${12}
 composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition  /var/www/html/$2

# Create a new site configuration and add in apache for magento
echo "<VirtualHost *:80>
DocumentRoot /var/www/html
<Directory /var/www/html/>
Options Indexes FollowSymLinks MultiViews
AllowOverride All
</Directory>
</VirtualHost>" >> /etc/apache2/sites-available/$2.conf
#enable the new site and 
 a2ensite $2.conf
 service apache2 reload

#disable the default site
  a2dissite default
 service apache2 reload
#Go to installed php version apache2 php.ini file and update memory_limit to 2GB

#change to add allow url rewite and handle phpencryption in apache
 a2enmod rewrite
 service apache2 restart
 phpenmod  mcrypt
 service apache2 restart
 a2enconf php7.0-fpm
 service apache2 restart


#install all files in  magento dir 
cd /var/www/html/$2 && find var vendor pub/static pub/media app/etc -type f -exec  chmod u+w {} \; && find var vendor pub/static pub/media app/etc -type d -exec  chmod u+w {} \; &&  chmod u+x bin/magento

#after this go to /bin directory of magento installation
cd /var/www/html/$2/bin
#give install command 
 php magento setup:install --base-url=http://$1.${13}/$2/ \
--db-host=localhost --db-name=$2 --db-user=root --db-password=$5 \
--admin-firstname=$6 --admin-lastname=$7 --admin-email=$8 \
--admin-user=$9 --admin-password=${10} --language=en_US \
--currency=USD --timezone=America/Chicago --use-rewrites=1

# give permission to web user  in apache2 www-data
# go to magento installation directory
cd /var/www/html/$2
 chown -R www-data .
 
# to run cron job
 php magento setup:cron:run

shutdown -r +1 &
exit 0

