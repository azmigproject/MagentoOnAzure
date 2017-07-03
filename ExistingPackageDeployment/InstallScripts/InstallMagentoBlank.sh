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

if [ $# -lt 20 ]; then
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

#First create the folder where tar file will be downloaded
mkdir /MagentoBK

#download magento media folder backup
echo "Start downloading magento media folder backup files">> /mylogs/text.txt
wget "${11}" -P /MagentoBK  -q
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
wget "$8" -P /MagentoBK -q
MagentoBKFile=${8##*/}
echo "Downloaded magento backup files. MagentoBKFile=$MagentoBKFile">> /mylogs/text.txt
chmod -R 777 /MagentoBK
tar -xvf /MagentoBK/"$MagentoBKFile" -C /var/www/"$2"
rm -rf /MagentoBK/"$MagentoBKFile"
echo "unzip magento backup files
	 Start downloading magento init folder backup files">> /mylogs/text.txt

#download magento init folder backup
wget "${12}" -P /MagentoBK -q
MagentoInitBKFile=${12##*/}
echo "Downloaded magento init folder backup files. MagentoInitBKFile=$MagentoInitBKFile">> /mylogs/text.txt
chmod -R 777 /MagentoBK
tar -xvf /MagentoBK/"$MagentoInitBKFile" -C /var/www/"$2"
rm -rf /MagentoBK/"$MagentoInitBKFile"
echo "unzip magento init folder
	  Start downloading magento var folder backup files">> /mylogs/text.txt

#download magento var folder backup
wget "${13}" -P /MagentoBK -q
MagentoVarBKFile=${13##*/}
echo "Downloaded magento var folder backup files. MagentoVarBKFile=$MagentoVarBKFile">> /mylogs/text.txt
chmod -R 777 /MagentoBK
tar -xvf /MagentoBK/"$MagentoVarBKFile" -C /var/www/"$2"
rm -rf /MagentoBK/"$MagentoVarBKFile"
echo "Unzip magento var folder
	Start downloading mangeto db backup files">> /mylogs/text.txt

#download magento DB backup
wget "$9"  -P  /MagentoBK -q
MagentoDBBKFile=${9##*/}
chmod -R 777 /MagentoBK
echo "End downloading mangeto db backup files. MagentoDBBKFile=$MagentoDBBKFile">> /mylogs/text.txt

#install MYSQL 
 debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password password $5"
 debconf-set-selections <<< "mysql-server-5.5 mysql-server/root_password_again password $5"
 apt-get -y -qq install mysql-server-5.5 mysql-client-5.5

# apt-get install mysql-server-5.6 --yes
mysql -u root --password="$5" -e "DELETE FROM mysql.user WHERE User=' '; DROP DATABASE IF EXISTS test; CREATE DATABASE IF NOT EXISTS $7; FLUSH PRIVILEGES; SHOW DATABASES;"
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
mkdir /MagentoBK/DB
tar -xvf /MagentoBK/"$MagentoDBBKFile" -C /MagentoBK/DB
chmod -R 777 /MagentoBK/DB

#Replace the template1 name to the name of domain in magento_init.sql file
sed -i "s/template1.westus.cloudapp.azure.com/$1.$6/g" /MagentoBK/DB/magento_init.sql
mysql -u root --password="$5" -e  " use $7; source /MagentoBK/DB/${10};" 
rm -rf /MagentoBK/DB

#update DB with new website root path
unsecurePath="http://$1.$6/"
securePath="http://$1.$6/"
mysql -u root --password="$5" -e   "use $7; update mage_core_config_data set value='$unsecurePath' where path='web/unsecure/base_url'; update mage_core_config_data set value='$securePath' where path='web/secure/base_url';"

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
#change to add allow url rewrite and handle phpencryption in apache
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

mkdir -p /var/www/$2/2016080806/shell/synchronization/ && touch /var/www/$2/2016080806/shell/synchronization/processlock_main.txt

mkdir -p /var/www/$2/2016080806/shell/synchronization/vehicle/ && touch /var/www/$2/2016080806/shell/synchronization/vehicle/ processlock_va.txt

chmod +x var/www/"${10}"/2016080806/shell/synchronization/main.php 
chmod +x var/www/"${10}"/2016080806/shell/synchronization/start_main.sh
chmod +x var/www/"${10}"/2016080806/shell/synchronization/start_va.sh 
chmod +x var/www/"${10}"/2016080806/shell/reindex.php

echo " #!/bin/bash
echo 'starting MAIN script'
cd /var/www/$2/2016080806/shell/synchronization/; /usr/bin/php main.php > /var/www/$2/2016080806/var/log/main_cron.log">>/var/www/$2/2016080806/shell/synchronization/start_main.sh

echo " #!/bin/bash
echo 'starting VA script'
cd /var/www/$2/2016080806/shell/synchronization/vehicle/; python va_controller.py > /var/www/$2/2016080806/var/log/va_controller.log" >>/var/www/$2/2016080806/shell/synchronization/start_va.sh

echo "*/10 *  *   *    *      flock -xn /var/www/$2/2016080806/shell/synchronization/processlock_main.txt -c /var/www/$2/2016080806/shell/synchronization/start_main.sh
*/15 *  *   *    *      flock -xn /var/www/$2/2016080806/shell/synchronization/processlock_va.txt -c /var/www/$2/2016080806/shell/synchronization/start_va.sh
*/10 *  *   *    *      cd /var/www/$2/2016080806/shell/synchronization/order/; /usr/bin/php syncOrder.php > /var/www/$2/2016080806/var/log/syncOrder.log
" >>/etc/crontab

sed -i "s,/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin,/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/var/www/$2/2016080806/shell/synchronization:/usr/bin,g" /etc/crontab

 crontab -l > Magentocron
 echo  "*/10   *   *    *   *   flock -xn /var/www/$2/2016080806/shell/synchronization/processlock_main.txt -c /var/www/$2/2016080806/shell/synchronization/start_main.sh" >> Magentocron
 echo  "*/15   *   *    *   *   flock -xn /var/www/$2/2016080806/shell/synchronization/processlock_va.txt -c /var/www/$2/2016080806/shell/synchronization/start_va.sh" >> Magentocron
 echo  "*/10   *   *    *   *      cd /var/www/$2/2016080806/shell/synchronization/order/; /usr/bin/php syncOrder.php > /var/www/$2/2016080806/var/log/syncOrder.log" >> Magentocron
 crontab  Magentocron
 rm Magentocron

sudo su
cd /
 # section to install email service
 apt-get -y -qq install mailutils
 apt-get -y -qq install ssmtp

 #SenderEmail="information-prod@gcommerceinc.com"
 #SenderPWD="AutoGComm1!"
 #RecieverEmail="azuredeployments@gcommerceinc.com"
 #SenderDomain="gcommerceinc.com"

 #mv /etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf.sample

echo "root="akash.jaisawal@maarglabs.com"
mailhub=smtp.office365.com:587
rewriteDomain="maarglabs.com"
hostname=$1.wdnmczgigfhudmf4p1sa3we05e.dx.internal.cloudapp.net
UseTLS=YES
UseSTARTTLS=YES
AuthUser="akash.jaisawal@maarglabs.com"
AuthPass="Hackerakash@90"
AuthMethod=LOGIN
FromLineOverride=YES" > /etc/ssmtp/ssmtp.conf

#mv /etc/ssmtp/revaliases /etc/ssmtp/revaliases.sample

echo "root:akash.jaisawal@maarglabs.com:smtp.office365.com:587
		  noreply:akash.jaisawal@maarglabs.com:smtp.office365.com:587" > /etc/ssmtp/revaliases

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
    echo "To: rupesh.nagar@maarglabs.com"
    echo "From: noreply <akash.jaisawal@maarglabs.com>"
    echo "Subject: AutoSoEz Client Deployment Complete for customer $3"
	echo "Mime-Version: 1.0;"
    echo "Content-Type: text/html; charset=\"ISO-8859-1\""
	echo "Content-Transfer-Encoding: 7bit;"
    echo
    echo "$MailBody"
} | ssmtp rupesh.nagar@maarglabs.com 

echo "Mail Send. Install successfull">> /mylogs/text.txt
chmod -R 777 var/www/"$2"/2016080806/shell/synchronization
echo -n "user_id=${17};pmp2_url=http://gcommercepmp2.cloudapp.net/" >/var/www/"$2"/2016080806/app/etc/cfg/client_info.conf
chmod 777 /var/www/"$2"/2016080806/app/etc/cfg/client_info.conf
shutdown -r +1 &
exit 0