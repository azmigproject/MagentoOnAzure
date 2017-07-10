#!/bin/bash
#
#
# Param info coming from InstallMagentoBlank file
# $1 - Domain name
# $2 - Folder name && DatabaseName
# $3 - Magento user name
# $5 - Magento SQL Password
# $6 - HOSTNAME
# $15 - VM USERName
# $16 - VM PAssword
# $17 - CustomerID
# $18 - Customertier
# $19 - Resourcegroup
# $21 - SenderEmail
# $22 - SenderPWD
# $23 - RecieverEmail
# $24 - SenderDomain

mkdir -p /var/www/$2/2016080806/shell/synchronization/ && touch /var/www/$2/2016080806/shell/synchronization/processlock_main.txt

mkdir -p /var/www/$2/2016080806/shell/synchronization/vehicle/ && touch /var/www/$2/2016080806/shell/synchronization/vehicle/ processlock_va.txt

chmod +x var/www/$2/2016080806/shell/synchronization/main.php 
chmod +x var/www/$2/2016080806/shell/synchronization/start_main.sh
chmod +x var/www/$2/2016080806/shell/synchronization/start_va.sh 
chmod +x var/www/$2/2016080806/shell/reindex.php

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

 #mv /etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf.sample

echo "root="${21}"
mailhub=smtp.office365.com:587
rewriteDomain="${24}"
hostname=$1.wdnmczgigfhudmf4p1sa3we05e.dx.internal.cloudapp.net
UseTLS=YES
UseSTARTTLS=YES
AuthUser="${21}"
AuthPass="${22}"
AuthMethod=LOGIN
FromLineOverride=YES" > /etc/ssmtp/ssmtp.conf

#mv /etc/ssmtp/revaliases /etc/ssmtp/revaliases.sample

echo "root:${21}:smtp.office365.com:587
		  noreply:${21}:smtp.office365.com:587" > /etc/ssmtp/revaliases

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
    echo "To: ${23}"
    echo "From: noreply <${21}>"
    echo "Subject: AutoSoEz Client Deployment Complete for customer $3"
	echo "Mime-Version: 1.0;"
    echo "Content-Type: text/html; charset=\"ISO-8859-1\""
	echo "Content-Transfer-Encoding: 7bit;"
    echo
    echo "$MailBody"
} | ssmtp ${23} 

echo "Mail Send. Install successfull">> /mylogs/text.txt
chmod -R 777 var/www/"$2"/2016080806/shell/synchronization
echo -n "user_id=${17};pmp2_url=http://gcommercepmp2.cloudapp.net/" >/var/www/"$2"/2016080806/app/etc/cfg/client_info.conf
chmod 777 /var/www/"$2"/2016080806/app/etc/cfg/client_info.conf
rm -rf var/www/"$2"/2016080806/var/cache/*