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
# $8 -magento admin surname
# $9 -magneto admin email
# $10 - magento admin usrname
#$11 - magento admin pwd
#$12 - magento connect public key
#$13 -magento connect private key
#steps to install apache2
if [ $1 ] && [ $2 ] && [ $3 ] && [ $4 ] && [ $5 ] && [ $6 ] && [ $7 ] && [ $8 ] && [ $9 ] && [ $10 ] && [ $11 ] && [ $12 ] && [ $13 ];
then
  #Installbasic
  sudo apt-get install \
    git \
    curl \
    unzip \
    --yes

#Install Apache
sudo apt-get -y install apache2

#install MYSQL
sudo apt-get-y install mysql5.6
sudo apt-get -y install mysql-server-5.6 mysql-client-5.6
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password $5"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $5"
sudo apt-get install mysql-server-5.6 --yes
mysql -u root --password="$5" -e"DELETE FROM mysql.user WHERE User=''; DROP DATABASE IF EXISTS test; CREATE DATABASE IF NOT EXISTS $2; FLUSH PRIVILEGES; SHOW DATABASES;"

#Install PHP
sudo apt-get install \
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

#Install PHP
#sudo apt-get -y install php7
#sudo apt-get -y install php7.0 libapache2-mod-php7.0 php7.0-mcrypt phpmyadmin
#sudo apt-get -y update
#sudo add-apt-repository ppa:ondrej/php
#sudo apt-get -y update
#sudo apt-get install -y php7.0 libapache2-mod-php7.0 php7.0 php7.0-common php7.0-gd php7.0-mysql php7.0-mcrypt php7.0-curl php7.0-intl php7.0-xsl php7.0-mbstring php7.0-zip php7.0-bcmath php7.0-iconv

#download composer and set
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

 # Create a new user for magento
sudo adduser $4 --gecos "Magento System,0,0,0" --disabled-password
echo "$3:$4" | sudo chpasswd
usermod -g www-data $3
mkdir /var/www/html/$2

#set rep.magento.com authendication options in order to get the details
 rm /var/www/html/$2/auth.json
 echo "{\"http-basic\":{\"repo.magento.com\":{\"username\":\""$12"\", \"password\":\""$13"\"}}}" >> /var/www/html/$2/auth.json

#Create New Magento Database

		
#mysql -u root -p
#create database magento;
#GRANT ALL ON magento.* TO magento@localhost IDENTIFIED BY 'magento';



#user composer to download the project repository. It  required to pass the  access keys which can be get by creating  account in https://marketplace.magento.com/customer/accessKeys/list/
# by default it will copy the files in ir /home/serveradmin/project-community-edition if  required to  install at any other dir  give the dir name <INSTALL DIR NAME> at the end of the given command
#$ composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition 

$ composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition  /var/www/html/$2

# Create a new site configuration and add in apache for magento
#sudo nano /etc/apache2/sites-available/magento.conf and add the following command

#<VirtualHost *:80>
#    DocumentRoot /var/www/html
#    <Directory /var/www/html/>
#        Options Indexes FollowSymLinks MultiViews
#        AllowOverride All
#    </Directory>
#</VirtualHost>

sudo echo "<VirtualHost *:80>\n
    DocumentRoot /var/www/html\n
    <Directory /var/www/html/>\n
        Options Indexes FollowSymLinks MultiViews\n
        AllowOverride All\n
    </Directory>\n
</VirtualHost>" >> /etc/apache2/sites-available/$2.conf

#enable the new site and 
sudo a2ensite $2.conf

#disable the default site
sudo  a2dissite default
#Go to installed php version apache2 php.ini file and update memory_limit to 2GB

#change to add allow url rewite and handle phpencryption in apache
sudo a2enmod rewrite
sudo php5enmod mcrypt


#install all files in dir /home/serveradmin/project-community-edition

find var vendor pub/static pub/media app/etc -type f -exec sudo chmod u+w {} \; && find var vendor pub/static pub/media app/etc -type d -exec sudo  chmod u+w {} \; &&  sudo chmod u+x bin/magento


#cd /home/serveradmin/project-community-edition && find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \; && find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \; && chmod u+x bin/magento

sudo cd /var/www/HTML/$2 && find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \; && find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \; && chmod u+x bin/magento

sudo cd /var/www/HTML/$2 && find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \; && find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \; && chmod u+x bin/magento

#after this go to /bin directory
sudo cd /var/www/HTML/$2/bin
#give install command 
php magento setup:install --base-url=http://$1.eastus.cloudapp.azure.com/$2/ \
--db-host=$3 --db-name=magento --db-user=root --db-password=$5 \
--admin-firstname=$6=User --admin-email=$9 \
--admin-user=$10 --admin-password=$11 --language=en_US \
--currency=USD --timezone=America/Chicago --use-rewrites=1

# give permission to web user  in apache2 www-data
# go to magento installation directory
sudo chown -R www-data .

# to run cron job
sudo php magento setup:cron:run

else
        echo ""
        echo "Missing parameters.";
        echo "1st parameter is domain name";
        echo "2nd parameter is magento folder name in which magento will installed";
        echo "3rd parameter is magento linux user (it will create it)";
        echo "4th parameter is magento linux password (it will create it)";
		echo "5th parameter is  mysql SQL Password";
		echo "6th parameter is magento admin first name";
		echo "7th parameter is magento admin last name";
		echo "8th parameter is magento admin surname";
		echo "9th parameter is admin email";
		echo "10th parameter is magento admin usrname";
		echo "11th parameter is magento admin pwd";
		echo "12th parameter is magento connect public key";
		echo "13th parameter is magento connect private key";
        #echo "Try this: magento-prepare.sh 2.0.7 mywebshop.com magento magento";
        echo "";
fi;

