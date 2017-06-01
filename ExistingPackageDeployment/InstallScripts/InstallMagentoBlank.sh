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

if [ $# -lt 19 ]; then
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
		
        #echo "Try this: magento-prepare.sh 2.0.7 mywebshop.com magento magento";
        echo "";
    exit 1
fi

START=$(date +%s)
echo "StartTime=$START | domain name=$1 |Folder name =$2| magento user name=$3|magento user passwor=$4|magento SQL Password=$5|HOSTNAME=$6| mysql SQL DB Name=$7| MagentoFileBackup=$8| MagentoDBBackup=$9| MagentoDB That need to be restore=${10}| MagentoDB Media folder backup=${11}| MagentoDB Init folder backup=${12}| MagentoDB Var folder backup=${13}| htaccess location=${14}">> /mylogs/text.txt
apt-get -y update 
#Installbasic
   apt-get install \
    git \
    curl \
    unzip \
	--yes

#Install Apache
 apt-get -y install apache2
echo "installed basic">> /mylogs/text.txt
#First create the folder where tar file will be downloaded
mkdir /MagentoBK
#download magento media folder backup
echo "Start downloading magento media folder backup files">> /mylogs/text.txt
wget "${11}" -P /MagentoBK  
MagentoMediaBKFile=${11##*/}
echo "Downloaded magento media folder backup files. MagentoMediaBKFile=$MagentoMediaBKFile">> /mylogs/text.txt
chmod -R 777 /MagentoBK
#create directory where code will store
echo "Created required directory and Start downloading magento media folder backup files">> /mylogs/text.txt
mkdir /var/www/"$2"
unzip /MagentoBK/"$MagentoMediaBKFile" -d /var/www/"$2"
rm -rf /MagentoBK/"$MagentoMediaBKFile" 
echo "Completed downloaded for magento media folder backup files and remove the backup file
      Start downloading magento backup files">> /mylogs/text.txt	
#download magento file backup
wget "$8" -P /MagentoBK
MagentoBKFile=${8##*/}
echo "Downloaded magento backup files. MagentoBKFile=$MagentoBKFile">> /mylogs/text.txt
chmod -R 777 /MagentoBK
tar -xvf /MagentoBK/"$MagentoBKFile" -C /var/www/"$2"
rm -rf /MagentoBK/"$MagentoBKFile"
echo "unzip magento backup files
	 Start downloading magento init folder backup files">> /mylogs/text.txt
#download magento init folder backup
wget "${12}" -P /MagentoBK 
MagentoInitBKFile=${12##*/}
echo "Downloaded magento init folder backup files. MagentoInitBKFile=$MagentoInitBKFile">> /mylogs/text.txt
chmod -R 777 /MagentoBK
tar -xvf /MagentoBK/"$MagentoInitBKFile" -C /var/www/"$2"
rm -rf /MagentoBK/"$MagentoInitBKFile"
echo "unzip magento init folder
	  Start downloading magento var folder backup files">> /mylogs/text.txt
#download magento var folder backup
wget "${13}" -P /MagentoBK
MagentoVarBKFile=${13##*/}
echo "Downloaded magento var folder backup files. MagentoVarBKFile=$MagentoVarBKFile">> /mylogs/text.txt
chmod -R 777 /MagentoBK
tar -xvf /MagentoBK/"$MagentoVarBKFile" -C /var/www/"$2"
rm -rf /MagentoBK/"$MagentoVarBKFile"
echo "Unzip magento var folder
	Start downloading mangeto db backup files">> /mylogs/text.txt
#download magento DB backup
wget "$9"  -P  /MagentoBK
MagentoDBBKFile=${9##*/}
chmod -R 777 /MagentoBK
echo "End downloading mangeto db backup files. MagentoDBBKFile=$MagentoDBBKFile">> /mylogs/text.txt
#install MYSQL 
 debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password password $5"
 debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password $5"
 apt-get -y install mysql-server-5.5 mysql-client-5.5
# apt-get install mysql-server-5.6 --yes
mysql -u root --password="$5" -e "DELETE FROM mysql.user WHERE User=' '; DROP DATABASE IF EXISTS test; CREATE DATABASE IF NOT EXISTS $7; FLUSH PRIVILEGES; SHOW DATABASES;"
echo "installed MYSQL and New DB">> /mylogs/text.txt
apt-get -y update
apt-get -y install php5
apt-get -y update
#Install PHP
apt-get -y install \
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
      
apt-get -y update
a2enmod proxy_fcgi setenvif
a2enconf php5-fpm
service php5-fpm restart
apt-get -y install apache2 php5 libapache2-mod-php5
service  apache2 restart
echo "installed PHP
	  End unziping magento files and removed corresponding tar files">> /mylogs/text.txt
#Uninstall DB backup
service  apache2 restart
mkdir /MagentoBK/DB
tar -xvf /MagentoBK/"$MagentoDBBKFile" -C /MagentoBK/DB
chmod -R 777 /MagentoBK/DB
#Replace the template1 name to the name of domain in magento_init.sql file
sed -i "s/template1.westus.cloudapp.azure.com/$1.$6/g" /MagentoBK/DB/magento_init.sql
mysql -u root --password="$5" -e  " use $7; source /MagentoBK/DB/${10};" 
rm -rf /MagentoBK/DB
#update DB with new website root path
unsecurePath="http://$1.$6/"
securePath="https://$1.$6/"
mysql -u root --password="$5" -e   "use $7; update mage_core_config_data set value='$unsecurePath' where path='web/unsecure/base_url'; update mage_core_config_data set value='$securePath' where path='web/secure/base_url';"
#Remove folder having zip files
echo "Removing downloaded zip files"
rm -rf /MagentoBK
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
 wget "${14}"
 fi
 cd / || exit
 # Create a new user for magento
 adduser "$3" --gecos "Magento System,0,0,0" --disabled-password
echo "$3:$4" |  chpasswd
 usermod -g www-data "$3"
 usermod -aG sudo "$3"
 usermod -aG root "$3"
 su -c "$3"
echo "$4"|sudo -S echo "create user"
echo "create user" | sudo tee -a /mylogs/text.txt > /dev/null
sudo chmod -R 755 /var/www
sudo  service apache2 restart
#install all files in  magento dir 
cd /var/www/"$2" || exit
sudo chmod -R 777 /var/www/"$2"
#enable the new site and 
sudo  a2ensite "$2".conf
sudo  service apache2 reload
#disable the default site
sudo   a2dissite 000-default
sudo  service apache2 reload
#Go to installed php version apache2 php.ini file and update memory_limit to 2GB
#change to add allow url rewite and handle phpencryption in apache
sudo  a2enmod rewrite
sudo  service apache2 restart
sudo  php5enmod  mcrypt
sudo  service apache2 restart
sudo  a2enconf php5-fpm
sudo  service apache2 restart
echo "Install Code" | sudo tee -a /mylogs/text.txt > /dev/null
# give permission to web user  in apache2 www-data
# go to magento installation directory
cd /var/www/"$2"/2016080806 || exit
echo "start giving permissions" | sudo tee -a /mylogs/text.txt > /dev/null
find var app/etc -type f -exec sudo  chmod g+w {} \;
find var app/etc -type d -exec sudo  chmod g+ws {} \;
sudo  chown -R "$3":www-data .
sudo chmod -R o+w media var 
sudo chmod o+w app/etc 
sudo chmod 550 mage 
echo "end giving permissions" | sudo tee -a /mylogs/text.txt > /dev/null
#sudo chmod -R 777 /var/www/$2/2016080806 
find . -type f -exec sudo chmod 644 {} \; 
find . -type d -exec sudo chmod 755 {} \; 
sudo chmod 550 mage 
sudo chmod -R 777  var 
sudo chmod -R 777 .var 
sudo chmod -R 777 pub/static 
sudo chmod -R 777 pub/media 
sudo chmod -R 777  media 
sudo chmod -R 777 .media 
cd /var/www/"$2" || exit
sudo chmod -R 777 .var 
sudo chmod -R 777 .media 
cd /var/www/"$2"/ || exit
sudo rm -rf .var/cache/*
echo "started cron" | sudo tee -a /mylogs/text.txt > /dev/null
sudo su
IP=$(curl ipinfo.io/ip)
echo "Installing Python-Pip functionality">> /mylogs/text.txt
apt-get -y install epel-release 
apt-get -y update 
apt-get -y install python-pip
echo "Installed Python-Pip functionality
	  Installing email functionality">> /mylogs/text.txt
# section to install email service
apt-get -y install mailutils
apt-get -y install ssmtp
#section for installing certbot SSL
apt-get -y install software-properties-common
add-apt-repository -y ppa:certbot/certbot
apt-get -y update
apt-get -y install python-certbot-apache 

if [ "${6/'azure.com'}" = "$6" ] ; then
  certbot certonly --webroot -w /var/www/"$2"/2016080806/ -d "$1.$6"  --agree-tos  --email azuredeployments@gcommerceinc.com -n
else
  certbot certonly --webroot -w /var/www/"$2"/2016080806/ -d "$1.$6"  --agree-tos  --email azuredeployments@gcommerceinc.com -n --test-cert 
fi
tempvar="$1.$6"
certbot --apache -d "$tempvar" --no-redirect --agree-tos  --email azuredeployments@gcommerceinc.com  -n  
echo "certbot renew -n --agree-tos --email azuredeployments@gcommerceinc.com --post-hook 'service apache2 restart'"> /etc/cron.daily/certbotcron
chmod 777 /etc/cron.daily/certbotcron
mv /etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf.sample

echo  "# Config file for sSMTP sendmail
#
# The person who gets all mail for userids < 1000
# Make this empty to disable rewriting.
#root=postmaster
root=information-prod@gcommerceinc.com

# The place where the mail goes. The actual machine name is required no
# MX records are consulted. Commonly mailhosts are named mail.domain.com
# mailhub=mail
mailhub=smtp.office365.com:587
AuthUser=information-prod@gcommerceinc.com
AuthPass=AutoGComm1!
UseTLS=YES
UseSTARTTLS=YES
TLS_CA_File=/etc/pki/tls/certs/ca-bundle.crt
# Where will the mail seem to come from?
#rewriteDomain=
rewriteDomain=gcommerceinc.com

# The full hostname
hostname=$1.wdnmczgigfhudmf4p1sa3we05e.dx.internal.cloudapp.net
#hostname=information-prod@gcommerceinc.com
# Are users allowed to set their own From: address?
# YES - Allow the user to specify their own From: address
# NO - Use the system generated From: address
FromLineOverride=YES" > /etc/ssmtp/ssmtp.conf

mv /etc/ssmtp/revaliases /etc/ssmtp/revaliases.sample

echo  "
# sSMTP aliases
#
# Format:       local_account:outgoing_address:mailhub
#
# Example: root:your_login@your.domain:mailhub.your.domain[:port]
# where [:port] is an optional port number that defaults to 25.
root:information-prod@gcommerceinc.com:smtp.office365.com:587
noreply:information-prod@gcommerceinc.com:smtp.office365.com:587
" > /etc/ssmtp/revaliases
END=$(date +%s)
DIFFMin=$((((END - START )/60)))
DIFFSec=$((((END - START )%60)))

MailBody="
AutoSoEz Client Deployment Complete. Details given below<BR>
<BR>
FrontEnd:http://$1.$6/<BR>
AdminEnd:http://$1.$6/zpanel<BR>
IP for SSH admin: $IP<BR>
<BR>
$DIFFMin minutes and $DIFFSec seconds to deploy<BR>
Resource Group:  ${19}<BR>
Domain Name:  $1<BR>
Customer Name:  ${17}<BR>
Customer Tier:  ${18}<BR>
MySQL Password:   $5<BR>
VM Admin User:  ${15}<BR>
VM Admin Pass:  ${16}"

{
    echo "To: azuredeployments@gcommerceinc.com"
    echo "From: noreply <information-prod@gcommerceinc.com>"
    echo "Subject: AutoSoEz Client Deployment Complete for customer $3"
	echo "Mime-Version: 1.0;"
    echo "Content-Type: text/html; charset=\"ISO-8859-1\""
	echo "Content-Transfer-Encoding: 7bit;"
    echo
    echo "$MailBody"
} | ssmtp azuredeployments@gcommerceinc.com 


echo "Mail Send. Install successfull">> /mylogs/text.txt
mkdir /var/www/app
mkdir /var/www/app/etc
chmod -R 777 /var/www/app/etc
echo "${17}" >>/var/www/app/etc/customer.txt
shutdown -r +1 &
exit 0