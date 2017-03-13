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
#$13 -HOSTNAME
#steps to install apache2
mkdir /mylogs
echo "testing">> /mylogs/text.txt
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
        echo "3rd parameter is server linux user (it will create it)";
        echo "4th parameter is server linux password (it will create it)";
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

echo "domain name=$1 |Folder name DatabaseName=$2| magento user name=$3|magento user passwor=$4|magento SQL Password=$5|magento admin first name=$6|magento admin last name=$7| magneto admin email=$8|magento admin usrname=$9|magento admin pwd=${10}|magento connect public key=${11}| magento connect private key=${12}|HOSTNAME=${13} ">> /mylogs/text.txt
apt-get update >> /mylogs/text.txt
#Installbasic
   apt-get install \
    git \
    curl \
    unzip \
    --yes
	
echo "installed basic">> /mylogs/text.txt
#Install Apache
 apt-get -y install apache2

 echo "installed Apache">> /mylogs/text.txt

#install MYSQL 
 debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password password $5"
 debconf-set-selections <<< "mysql-server-5.7 mysql-server/root_password_again password $5"
 apt-get -y install mysql-server-5.7 mysql-client-5.7 >> /mylogs/text.txt
# apt-get install mysql-server-5.6 --yes
mysql -u root --password="$5" -e"DELETE FROM mysql.user WHERE User=''; DROP DATABASE IF EXISTS test; CREATE DATABASE IF NOT EXISTS $2; FLUSH PRIVILEGES; SHOW DATABASES;" >> /mylogs/text.txt

echo "installed MYSQL">> /mylogs/text.txt
# Update apt-get 
apt-get update >> /mylogs/text.txt

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
    --yes >> /mylogs/text.txt
apt-get update >> /mylogs/text.txt
a2enmod proxy_fcgi setenvif >> /mylogs/text.txt
 a2enconf php7.0-fpm >> /mylogs/text.txt

 service php7.0-fpm restart >> /mylogs/text.txt
 apt-get -y install apache2 php7.0 libapache2-mod-php7.0 >> /mylogs/text.txt
  service apache2 restart >> /mylogs/text.txt
  echo "installed PHP">> /mylogs/text.txt
  
 apt-get -y install curl php7.0-cli git
 echo "installed curl php7.0-cli git">> /mylogs/text.txt
#download composer and set
#curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer >> /mylogs/text.txt
#curl -sS https://getcomposer.org/installer |  php >> /mylogs/text.txt
wget https://getcomposer.org/composer.phar -O composer.phar >> /mylogs/text.txt
mv composer.phar /usr/local/bin/composer >> /mylogs/text.txt
chmod 777  /usr/local/bin/composer >> /mylogs/text.txt
 echo "downloaded composer ">> /mylogs/text.txt
 composer>> /mylogs/text.txt
systemctl restart apache2

# wget https://raw.githubusercontent.com/azmigproject/MagentoOnAzure/master/InstallScripts/InstallMagento_After_Reboot
# chmod 777 InstallMagento_After_Reboot.sh
# echo "PATH=/sbin:/bin:/usr/sbin:/usr/bin" >> /etc/init.d/After_Script
# chmod 777 /etc/init.d/After_Script
# echo ' case $1 in' >> /etc/init.d/After_Script
# echo " start)" >> /etc/init.d/After_Scrip
# echo "bash /InstallMagento_After_Reboot.sh '$1' '$2' '$3' '$4' '$5' '$6' '$7' '$8' '$9' '${10}' '${11}' '${12}' '${13}'" >> /etc/init.d/After_Script
# echo ";;" >> /etc/init.d/After_Script
# echo " stop|restart|reload)" >> /etc/init.d/After_Script
# echo " ;;">> /etc/init.d/After_Script
# echo "esac">> /etc/init.d/After_Script
# chmod 777 /etc/init.d/After_Script
# update-rc.d  After_Script.sh defaults
# reboot
 #mv composer.phar /usr/local/bin/composer

 # Create a new user for magento
 adduser $3 --gecos "Magento System,0,0,0" --disabled-password
echo "$3:$4" |  chpasswd
 chmod 777 /mylogs/text.txt
 usermod -g www-data $3
 usermod -aG root $3
 su $3
echo '$4'|sudo -S echo "create user">> /mylogs/text.txt
sudo echo "create user">> /mylogs/text.txt
sudo  systemctl restart apache2
#set rep.magento.com authendication options in order to get the details
sudo  composer config -g http-basic.repo.magento.com ${11} ${12}
sudo  echo "composer config -g http-basic.repo.magento.com ${11} ${12}">> /mylogs/text.txt
sudo  echo "composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition  /var/www/html/$2">> /mylogs/text.txt
sudo  composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition  /var/www/html/$2 >> /mylogs/text.txt

 sudo  echo "Get magento code">> /mylogs/text.txt

# Create a new site configuration and add in apache for magento
sudo  echo "<VirtualHost *:80>
DocumentRoot /var/www/html
<Directory /var/www/html/>
Options Indexes FollowSymLinks MultiViews
AllowOverride All
</Directory>
</VirtualHost>" >> /etc/apache2/sites-available/$2.conf
#enable the new site and 
sudo  a2ensite $2.conf
sudo  service apache2 reload

#disable the default site
sudo   a2dissite 000-default
sudo  service apache2 reload
#Go to installed php version apache2 php.ini file and update memory_limit to 2GB

#change to add allow url rewite and handle phpencryption in apache
sudo  a2enmod rewrite
sudo  service apache2 restart
 sudo  phpenmod  mcrypt
 sudo  service apache2 restart
 sudo  a2enconf php7.0-fpm
 sudo  service apache2 restart

 sudo  echo "Install Code">> /mylogs/text.txt
#install all files in  magento dir 
#cd /var/www/html/$2 && find var vendor pub/static pub/media app/etc -type f -exec sudo  chmod u+w {} \; && find var vendor pub/static pub/media app/etc -type d -exec sudo  chmod u+w {} \; &&  sudo  chmod u+x bin/magento

#after this go to /bin directory of magento installation
cd /var/www/html/$2/bin
#give install command 
 sudo  echo "Running Install magento command">> /mylogs/text.txt
sudo  php magento setup:install --base-url=http://$1.${13}/$2/ \
--db-host=localhost --db-name=$2 --db-user=root --db-password=$5 \
--admin-firstname=$6 --admin-lastname=$7 --admin-email=$8 \
--admin-user=$9 --admin-password=${10} --language=en_US \
--currency=USD --timezone=America/Chicago --use-rewrites=1
sudo  echo "magento installation complete">> /mylogs/text.txt
# give permission to web user  in apache2 www-data
# go to magento installation directory
cd /var/www/html/$2
 sudo  echo "start giving permissions">> /mylogs/text.txt
 find var vendor pub/static pub/media app/etc -type f -exec sudo  chmod g+w {} \;
 find var vendor pub/static pub/media app/etc -type d -exec sudo  chmod g+ws {} \;
 sudo  chown -R magento:www-data .
sudo  chmod u+x bin/magento
 sudo  echo "end giving permissions">> /mylogs/text.txt
# to run cron job
cd /var/www/html/$2/bin
 sudo  php magento setup:cron:run
  sudo  echo "started cron">> /mylogs/text.txt
 
 sudo  echo "Install successfull">> /mylogs/text.txt
 sudo su
shutdown -r +1 &
exit 0

