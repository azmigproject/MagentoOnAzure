#!/bin/bash
#
#Parms info 
# $1 -domain name 
# $2 - Folder name && DatabaseName
# $3 - magento user name
# $4 - magento user password
# $5 - magento SQL Password
#$6 -HOSTNAME
#$7 - MYSQL DB NAME
#$8 - MagentoFileBackup
#$9 - MagentoDBBackup
#$10 - Magento DB that need to be backup
#$11 - Magento Media Folder backup
#$12 - Magento Init Folder backup
#$13 - Magento Var Folder backup
#$14- Magento htaccess file
#$15- VM USERName
#$16- VM PAssword
#$17- customerID
#$18- customertier
#$19- resourcegroup
#$20- parameter is Monitoring tool files
# $21 - SenderEmail
# $22 - SenderPWD
# $23 - RecieverEmail
# $24 - SenderDomain
# $25 - tfsAccessToken
# $26 - tfsAgentPool

#steps to install apache2
mkdir /mylogs
echo "testing">> /mylogs/text.txt
chmod 777 /mylogs/text.txt

if [ $# -lt 26 ]; then
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
		echo "11th parameter is Magento Media folder backup";
		echo "12th parameter is Magento Init folder backup";
		echo "13th parameter is Magento Var folder backup";
		echo "14th parameter is default htaccess file path";
		echo "15th parameter is VM UserName";
		echo "16th parameter is VM Password";
		echo "17th parameter is customerID";
		echo "18th parameter is customerTier";
		echo "19th parameter is resourcegroup name";
		echo "20th parameter is Monitoring tool files";
		echo "21st parameter is SenderEmail";
		echo "22nd parameter is SenderPWD";
		echo "23rd parameter is RecieverEmail";
		echo "24th parameter is SenderDomain";
		echo "25th parameter is TFS Access Token for setting Agent in remote machine";
		echo "26th parameter is TFS Agent Pool Name for listing agent in the pool in TFS";
        #echo "Try this: magento-prepare.sh 2.0.7 mywebshop.com magento magento";
        echo "";
    exit 1
fi

START=$(date +%s)
echo "StartTime=$START | domain name=$1 |Folder name =$2| magento user name=$3|magento user passwor=$4|magento SQL Password=$5|HOSTNAME=$6| mysql SQL DB Name=$7| MagentoFileBackup=$8| MagentoDBBackup=$9| MagentoDB That need to be restore=${10}| MagentoDB Media folder backup=${11}| MagentoDB Init folder backup=${12}| MagentoDB Var folder backup=${13}| htaccess location=${14}">> /mylogs/text.txt
apt-get -y -qq update 
#Installbasic
   apt-get -qq install \
    git \
    curl \
    unzip \
	--yes

#Install Apache
 apt-get -y  -qq install apache2
echo "installed basic">> /mylogs/text.txt


# Download magento media folder backup
# Create directory where code will store
# Download magento file backup
# Download magento init folder backup
# Download magento var folder backup
# Download magento DB backup

curl  https://raw.githubusercontent.com/azmigproject/MagentoOnAzure/master/PackageDevelopment/InstallScripts/GcMagentoArtifacts.sh | bash -s "${2}" "${8}" "${9}" "${11}" "${12}" "${13}"
#sh ./GcMagentoArtifacts.sh

#install MYSQL 
 debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password password $5"
 debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password $5"
 apt-get -y -qq install mysql-server-5.5 mysql-client-5.5

# apt-get install mysql-server-5.6 --yes
mysql -u root --password="$5" -e "DELETE FROM mysql.user WHERE User=' '; DROP DATABASE IF EXISTS test; CREATE DATABASE IF NOT EXISTS $7; FLUSH PRIVILEGES; SHOW DATABASES;"
mysql -u root --password="$5" -e " Grant ALL on *.* To 'root'@'localhost'; FLUSH PRIVILEGES;"
mysql -u root --password="$5" -e " GRANT ALL PRIVILEGES ON *.* TO 'root' IDENTIFIED BY '$5' WITH GRANT OPTION;FLUSH PRIVILEGES;"
echo "installed MYSQL and New DB">> /mylogs/text.txt
apt-get -y -qq update
apt-get -y -qq install php5
apt-get -y -qq update

#Install PHP
apt-get -y -qq install \
  php5-fpm \
 php5-mysql \
php5-mcrypt \
php5-curl \
php5-cli \
php5-gd \
 php5-xsl \
   php5-json \
   php5-intl \
     php5-dev \
   php5-common       
apt-get -y -qq update
a2enmod proxy_fcgi setenvif
a2enconf php5-fpm
service php5-fpm restart
apt-get -y install apache2 php5 libapache2-mod-php5
service  apache2 restart
echo "installed PHP
	  End unziping magento files and removed corresponding tar files">> /mylogs/text.txt

#Uninstall DB backup
service  apache2 restart

#Replace the template1 name to the name of domain in magento_init.sql file
sed -i "s/template1.westus.cloudapp.azure.com/$1.$6/g" /MagentoBK/DB/magento_init.sql
mysql -u root --password="$5" -e  " use $7; source /MagentoBK/DB/${10};" 
rm -rf /MagentoBK/DB

#update DB with new website root path
unsecurePath="http://$1.$6/"
securePath="http://$1.$6/"
mysql -u root --password="$5" -e   "use $7; update mage_core_config_data set value='$unsecurePath' where path='web/unsecure/base_url'; update mage_core_config_data set value='$securePath' where path='web/secure/base_url';"
update `mage_core_config_data` SET value = 'smtp' where path ='smtppro/general/option';
update `mage_core_config_data` SET value = 'login' where path ='smtppro/general/smtp_authentication';
update `mage_core_config_data` SET value = 'AKIAIRWZ2JASC4R4CSWA' where path ='smtppro/general/smtp_username';
update `mage_core_config_data` SET value = 'FgzGggO6TWWF8QJHCtpjKZiM7uiiKXMrc4SSQp8mmcBmQOHI2F7EHvDaxVepQbNM' where path ='smtppro/general/smtp_password';
update `mage_core_config_data` SET value = 'email-smtp.us-west-2.amazonaws.com' where path ='smtppro/general/smtp_host';
update `mage_core_config_data` SET value = '587' where path ='smtppro/general/smtp_port';
update `mage_core_config_data` SET value = 'tls' where path ='smtppro/general/smtp_ssl';

# if testing locally please comment below Mysql command
   mysql -u root --password="$5" -e   "use $7; update magento.mage_core_config_data
   set value = 'https://autosoez.azureedge.net/${17}/' where path in( 'web/secure/base_media_url','web/unsecure/base_media_url');"  

#Replace the database details in local.xml file
sed -i "s/74.208.174.2/localhost/g" /var/www/"$2"/.init/local.xml
sed -i "s/aat01_www/$7/g" /var/www/"$2"/.init/local.xml
sed -i "s/aat01/root/g" /var/www/"$2"/.init/local.xml
sed -i "s/DiplVYtpSM0XeuKU/$5/g" /var/www/"$2"/.init/local.xml
echo "updated local.xml file">> /mylogs/text.txt

# Create a new site configuration and add in apache for magento
echo "<VirtualHost *:80>
	ServerName $1.$6
        ServerAlias  $1.$6
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/$2/2016080806
        ErrorLog ${APACHE_LOG_DIR}/error.log
       CustomLog ${APACHE_LOG_DIR}/access.log combined
	   <Directory /var/www/$2/2016080806/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>
</VirtualHost>" >> /etc/apache2/sites-available/"$2".conf

# Check if .htaccess file is Missing than add it from default location
cd /var/www/"$2"/2016080806 || exit
if [ ! -f ".htaccess" ]; then
 echo "copying htaccess file" >> /mylogs/text.txt;
 wget "${14}" -q
 fi
 cd / || exit

 chmod -R 755 /var/www
  service apache2 restart

#install all files in  magento dir 
cd /var/www/"$2" || exit
 chmod -R 777 /var/www/"$2"

#enable the new site and 
  a2ensite "$2".conf
 service apache2 reload

#disable the default site
   a2dissite 000-default
  service apache2 reload

#Go to installed php version apache2 php.ini file and update memory_limit to 2GB
#change to add allow url rewrite and handle phpencryption in apache
 a2enmod rewrite
  service apache2 restart
  php5enmod  mcrypt
 service apache2 restart
  a2enconf php5-fpm
 service apache2 restart
echo "Install Code" | tee -a /mylogs/text.txt > /dev/null

# give permission to web user  in apache2 www-data
# go to magento installation directory
cd /var/www/"$2"/2016080806 || exit
echo "start giving permissions" | tee -a /mylogs/text.txt > /dev/null

find var app/etc -type f -exec chmod g+w {} \;
find var app/etc -type d -exec chmod g+ws {} \;
  chown -R "$3":www-data .
 chmod -R o+w media var 
 chmod o+w app/etc 
 chmod 550 mage 
echo "end giving permissions" | tee -a /mylogs/text.txt > /dev/null

find . -type f -exec chmod 644 {} \; 
find . -type d -exec chmod 755 {} \; 
 chmod 550 mage 
 chmod -R 777  var 
# chmod -R 777 .var 
 chmod -R 777 pub/static 
 chmod -R 777 pub/media 
 chmod -R 777  media 
# chmod -R 777 .media 
cd /var/www/"$2" || exit
 #chmod -R 777 .var 
 #chmod -R 777 .media 
#cd /var/www/"$2"/ || exit
 #rm -rf .var/cache/*
echo "started cron" | tee -a /mylogs/text.txt > /dev/null

IP=$(curl ipinfo.io/ip)
echo "Installing Python-Pip functionality">> /mylogs/text.txt
apt-get -y -qq install epel-release 
apt-get -y -qq update 
apt-get -y -qq install python-pip
echo "Installed Python-Pip functionality
	  Installing email functionality">> /mylogs/text.txt


#section for installing certbot SSL
apt-get -y -qq install software-properties-common
add-apt-repository -y  ppa:certbot/certbot
apt-get -y -qq update
apt-get -y -qq install python-certbot-apache 

#Install Monitoring tools
apt-get -y -qq install xinetd
wget "${20}" -P /MagentoBK -q
unzip /MagentoBK/MonitoringAgentFiles -d /MagentoBK/
mv  /MagentoBK/check_mk_agent  /usr/bin  
chmod +x /usr/bin/check_mk_agent
mv  /MagentoBK/waitmax /usr/bin  
chmod +x  /usr/bin/waitmax 
mv /MagentoBK/check_mk /etc/xinetd.d
/etc/init.d/xinetd restart
rm -rf /MagentoBK
#end Monitoring tools

#Remove folder having zip files
echo "Removing downloaded zip files"

# Cron Tab Update
# New cron job
# section to install email service

apt-get -y -qq install mailutils 
apt-get -y -qq install ssmtp


curl  https://raw.githubusercontent.com/azmigproject/MagentoOnAzure/master/PackageDevelopment/InstallScripts/GCMagentoCronMail.sh | bash -s "${1}" "${2}" "${3}" "${5}" "${6}" "${15}" "${16}" "${17}" "${18}" "${19}" "${21}" "${22}" "${23}" "${24}"
#sh ./GCMagentoCronMail.sh
rm -rf /var/www/"$2"/2016080806/var/cache/*
apt-get install htop
wget "https://raw.githubusercontent.com/azmigproject/MagentoOnAzure/master/ExistingPackageDeployment/InstallScripts/InstallAgent.sh"
chmod 777 InstallAgent.sh
mkdir /var/tfsworkfolder
echo '/InstallAgent.sh "${25}" "${26}" "${15}" "agent${17}${18}" "/var/tfsworkfolder" https://gcommerceinc.visualstudio.com'>> /mylogs/text.txt
./InstallAgent.sh "${25}" "${26}" "${15}" "agent${17}${18}" "/var/tfsworkfolder" https://gcommerceinc.visualstudio.com >> /mylogs/text.txt
