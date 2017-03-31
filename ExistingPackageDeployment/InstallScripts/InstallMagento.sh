#!/bin/bash
#
#Parms info 
# $1 -domain name 
# $2 - Folder name && DatabaseName
# $3 - magento user name
# $4 - magento user password
# $5 - magento SQL Password
#$6 -HOSTNAME
#7 - MYSQL DB NAME
#$8 - MagentoFileBackup
#$9 - MagentoDBBackup
#$10 - Magento DB that need to be backup
#steps to install apache2
mkdir /mylogs
echo "testing">> /mylogs/text.txt
chmod 777 /mylogs/text.txt
set -x
#set -xeuo pipefail to check if root user 

if [[ $(id -u) -ne 0 ]] ; then
    echo "Must be run as root"
    exit 1
fi

if [ $# < 10 ]; then
     echo ""
        echo "Missing parameters.";
        echo "1st parameter is domain name";
        echo "2nd parameter is magento folder name in which magento will installed";
        echo "3rd parameter is server linux user (it will create it)";
        echo "4th parameter is server linux password (it will create it)";
		echo "5th parameter is  mysql SQL Password";
		echo "6th parameter is HOSTNAME";
		echo "7th parameter is  mysql SQL DB Name";
		echo "8th parameter is  MagentoFileBackup";
		echo "9th parameter is MagentoDBBackup";
		echo "10th parameter is Magento DB that need to be backup";
        #echo "Try this: magento-prepare.sh 2.0.7 mywebshop.com magento magento";
        echo "";
    exit 1
fi

echo "domain name=$1 |Folder name =$2| magento user name=$3|magento user passwor=$4|magento SQL Password=$5|HOSTNAME=$6| mysql SQL DB Name=$7| MagentoFileBackup=$8| MagentoDBBackup=$9| MagentoDB That need to be restore=${10}">> /mylogs/text.txt
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

apt-get install software-properties-common
sudo add-apt-repository -y ppa:ondrej/mysql-5.5
sudo apt-get update


#install MYSQL 
 debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password password $5"
 debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password $5"
 apt-get -y install mysql-server-5.5 mysql-client-5.5 >> /mylogs/text.txt
# apt-get install mysql-server-5.6 --yes
mysql -u root --password="$5" -e"DELETE FROM mysql.user WHERE User=''; DROP DATABASE IF EXISTS test; CREATE DATABASE IF NOT EXISTS $7; FLUSH PRIVILEGES; SHOW DATABASES;" >> /mylogs/text.txt



echo "installed MYSQL and New DB">> /mylogs/text.txt

apt-get install software-properties-common
add-apt-repository -y ppa:ondrej/php
apt-get update
apt-get install php5.6 >> /mylogs/text.txt
apt-get install php5.6-mbstring php5.6-mcrypt php5.6-mysql php5.6-xml >> /mylogs/text.txt

# Update apt-get 
apt-get update >> /mylogs/text.txt

#Install PHP

apt-get install \
    php5.6-fpm \
    php5.6-mysql \
    php5.6-mcrypt \
    php5.6-curl \
   php5.6-cli \
    php5.6-gd \
    php5.6-xsl \
    php5.6-json \
   php5.6-intl \
    php5.6-dev \
    php5.6-common \
    php5.6-soap \
    php5.6-mbstring \
    php5.6-zip \
    --yes >> /mylogs/text.txt


 #apt-get install \
  #  php-fpm \
   # php-mysql \
    #php-mcrypt \
    #php-curl \
    #php-cli \
   # php-gd \
   # php7.0-xsl \
    #php-json \
    #php-intl \
    #php-pear \
    #php-dev \
    #php-common \
    #php-soap \
    #php-mbstring \
    #php-zip \
    #--yes >> /mylogs/text.txt
apt-get update >> /mylogs/text.txt
a2enmod proxy_fcgi setenvif >> /mylogs/text.txt
a2enconf php5.6-fpm >> /mylogs/text.txt
service php5.6-fpm restart >> /mylogs/text.txt
apt-get -y install apache2 php5.6 libapache2-mod-php5.6 >> /mylogs/text.txt
#a2enmod proxy_fcgi setenvif >> /mylogs/text.txt
#a2enconf php7.0-fpm >> /mylogs/text.txt
#service php7.0-fpm restart >> /mylogs/text.txt
#apt-get -y install apache2 php7.0 libapache2-mod-php7.0 >> /mylogs/text.txt
service apache2 restart >> /mylogs/text.txt
echo "installed PHP">> /mylogs/text.txt
  
apt-get -y install curl php7.0-cli git
echo "installed curl php7.0-cli git">> /mylogs/text.txt

systemctl restart apache2

mkdir /MagentoBK
chmod -R 777 /MagentoBK
#download magento file backup
echo "Start downloading magento backup files">> /mylogs/text.txt
wget $8 -P /MagentoBK  >> /mylogs/text.txt
MagentoBKFile=${8##*/}
echo "Downloaded magento backup files. MagentoBKFile=$MagentoBKFile">> /mylogs/text.txt


#download magento DB backup
echo "Start downloading mangeto db backup files">> /mylogs/text.txt
wget $9  -P  /MagentoBK >> /mylogs/text.txt
MagentoDBBKFile=${9##*/}
chmod -R 777 /MagentoBK
echo "End downloading mangeto db backup files. MagentoDBBKFile=$MagentoDBBKFile">> /mylogs/text.txt

#create directory where code will store

mkdir /var/www/$2
tar -xvf /MagentoBK/$MagentoBKFile -C /var/www/$2
echo "End unziping magento files">> /mylogs/text.txt
#Uninstall DB backup
systemctl restart apache2
mkdir /MagentoBK/DB
chmod -R 777 /MagentoBK/DB
#unzip /MagentoBK/$MagentoDBBKFile -d /MagentoBK/DB
tar -xvf /MagentoBK/$MagentoDBBKFile -C /MagentoBK/DB

mysql -u root --password="$5" -e" use $7; source /MagentoBK/DB/${10};" >> /mylogs/text.txt
rm -rf /MagentoBK/DB
#update DB with new website root path
unsecurePath="http://$1.$6/"
securePath="https://$1.$6/"
mysql -u root --password="$5" -e "
 use $7; update mage_core_config_data set value='$unsecurePath' where path='web/unsecure/base_url'; update mage_core_config_data set value='$securePath' where path='web/secure/base_url';" >> /mylogs/text.txt

#Remove folder having zip files
echo "Removing downloaded zip files">> /mylogs/text.txt
rm -rf /MagentoBK >> /mylogs/text.txt

# Create a new site configuration and add in apache for magento
echo "<VirtualHost *:80>
	ServerName $1.$6
        ServerAlias $1.$6
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/$2/2016080806
        ErrorLog ${APACHE_LOG_DIR}/error.log
       CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" >> /etc/apache2/sites-available/$2.conf

 # Create a new user for magento
 adduser $3 --gecos "Magento System,0,0,0" --disabled-password
echo "$3:$4" |  chpasswd
 
 usermod -g www-data $3
 usermod -aG sudo $3
  usermod -aG root $3

 su $3
echo '$4'|sudo -S echo "create user">> /mylogs/text.txt
sudo echo "create user">> /mylogs/text.txt
sudo chmod -R 755 /var/www
sudo  systemctl restart apache2

#install all files in  magento dir 

cd /var/www/$2
sudo chmod -R 777 /var/www/$2


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
sudo  a2enconf php5.6-fpm
sudo  service apache2 restart
sudo  echo "Install Code">> /mylogs/text.txt

#Update the database details in local files
#filexml="app/etc/local.xml"
#filephp="app/etc/env.php"
#if [ -f "$filexml" ] 
#else if [ -f "filephp" ] 
#fi



# give permission to web user  in apache2 www-data
# go to magento installation directory
cd /var/www/$2/
sudo  echo "start giving permissions">> /mylogs/text.txt
find var vendor pub/static pub/media app/etc -type f -exec sudo  chmod g+w {} \;
find var vendor pub/static pub/media app/etc -type d -exec sudo  chmod g+ws {} \;
sudo  chown -R $3:www-data .
sudo  chmod u+x bin/magento
sudo  echo "end giving permissions">> /mylogs/text.txt

# to run cron job
cd /var/www/$2/bin
#sudo  php magento setup:cron:run
sudo chmod -R 777 /var/www/$2
sudo  echo "started cron">> /mylogs/text.txt
sudo  echo "Install successfull">> /mylogs/text.txt
sudo su
shutdown -r +1 &
exit 0