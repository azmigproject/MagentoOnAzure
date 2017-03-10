#!/bin/bash
#
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

echo "IN After Execute File">>/mylogs/text.txt

echo "domain name=$1 |Folder name DatabaseName=$2| magento user name=$3|magento user passwor=$4|magento SQL Password=$5|magento admin first name=$6|magento admin last name=$7| magneto admin email=$8|magento admin usrname=$9|magento admin pwd=${10}|magento connect public key=${11}| magento connect private key=${12}|HOSTNAME=${13} ">> /mylogs/text.txt

# Create a new user for magento
 adduser $3 --gecos "Magento System,0,0,0" --disabled-password
echo "$3:$4" |  chpasswd
 usermod -g www-data $3

echo "create user">> /mylogs/text.txt

#set rep.magento.com authendication options in order to get the details
 composer config -g http-basic.repo.magento.com ${11} ${12}
 echo "composer config -g http-basic.repo.magento.com ${11} ${12}">> /mylogs/text.txt
 echo "composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition  /var/www/html/$2">> /mylogs/text.txt
 composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition  /var/www/html/$2 >> /mylogs/text.txt

 echo "Get magento code">> /mylogs/text.txt

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
  a2dissite 000-default
 service apache2 reload
#Go to installed php version apache2 php.ini file and update memory_limit to 2GB

#change to add allow url rewite and handle phpencryption in apache
 a2enmod rewrite
 service apache2 restart
 phpenmod  mcrypt
 service apache2 restart
 a2enconf php7.0-fpm
 service apache2 restart

 echo "Install Code">> /mylogs/text.txt
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

 
 echo "Install successfull">> /mylogs/text.txt
shutdown -r +1 &
exit 0

