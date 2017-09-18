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

# Parm used in CronMail
# $1 - Domain name
# $2 - Folder name && DatabaseName
# $3 - Magento user name
# $4 - Magento SQL Password
# $5 - HOSTNAME
# $6 - VM USERName
# $7 - VM PAssword
# $8 - CustomerID
# $9 - Customertier
# $10 - Resourcegroup
# $11 - SenderEmail
# $12 - SenderPWD
# $13 - RecieverEmail
# $14 - SenderDomain

set -x
#set -xeuo pipefail to check if root user 

if [[ $(id -u) -ne 0 ]] ; then
    echo "Must be run as root"
    exit 1
fi

mkdir -p /var/www/$2/2016080806/shell/synchronization/ && touch /var/www/$2/2016080806/shell/synchronization/processlock_main.txt

mkdir -p /var/www/$2/2016080806/shell/synchronization/vehicle/ && touch /var/www/$2/2016080806/shell/synchronization/vehicle/ processlock_va.txt

chmod +x /var/www/$2/2016080806/shell/synchronization/main.php 
chmod +x /var/www/$2/2016080806/shell/synchronization/start_main.sh
chmod +x /var/www/$2/2016080806/shell/synchronization/start_va.sh 
chmod +x /var/www/$2/2016080806/shell/reindex.php

echo " #!/bin/bash
echo 'starting MAIN script'
cd /var/www/$2/2016080806/shell/synchronization/; /usr/bin/php main.php > /var/www/$2/2016080806/var/log/main_cron.log">/var/www/$2/2016080806/shell/synchronization/start_main.sh

echo " #!/bin/bash
echo 'starting VA script'
cd /var/www/$2/2016080806/shell/synchronization/vehicle/; python va_controller.py > /var/www/$2/2016080806/var/log/va_controller.log" >/var/www/$2/2016080806/shell/synchronization/start_va.sh

echo "*/10 *  *   *    *      flock -xn /var/www/$2/2016080806/shell/synchronization/processlock_main.txt -c /var/www/$2/2016080806/shell/synchronization/start_main.sh
*/15 *  *   *    *      flock -xn /var/www/$2/2016080806/shell/synchronization/processlock_va.txt -c /var/www/$2/2016080806/shell/synchronization/start_va.sh
*/10 *  *   *    *      cd /var/www/$2/2016080806/shell/synchronization/order/; /usr/bin/php syncOrder.php > /var/www/$2/2016080806/var/log/syncOrder.log
*/5 *  *   *    *      cd /var/www/$2/2016080806/shell/synchronization/order/; /usr/bin/php getOrderData.php
*/5 *  *   *    *      cd /var/www/$2/2016080806/shell/synchronization/order/; /usr/bin/php syncOrderStatus.php
*/5 *  *   *    *      cd /var/www/$2/2016080806/shell/synchronization/order/; /usr/bin/php syncOrderTracking.php
" >>/etc/crontab

sed -i "s,/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin,/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/var/www/$2/2016080806/shell/synchronization:/usr/bin,g" /etc/crontab

 crontab -l > Magentocron
 echo  "*/10   *   *    *   *   flock -xn /var/www/$2/2016080806/shell/synchronization/processlock_main.txt -c /var/www/$2/2016080806/shell/synchronization/start_main.sh" >> Magentocron
 echo  "*/15   *   *    *   *   flock -xn /var/www/$2/2016080806/shell/synchronization/processlock_va.txt -c /var/www/$2/2016080806/shell/synchronization/start_va.sh" >> Magentocron
 echo  "*/10   *   *    *   *      cd /var/www/$2/2016080806/shell/synchronization/order/; /usr/bin/php syncOrder.php > /var/www/$2/2016080806/var/log/syncOrder.log" >> Magentocron
 echo  "*/5 *  *   *    *      cd /var/www/$2/2016080806/shell/synchronization/order/; /usr/bin/php getOrderData.php" >> Magentocron
 echo  "*/5 *  *   *    *      cd /var/www/$2/2016080806/shell/synchronization/order/; /usr/bin/php syncOrderStatus.php" >> Magentocron
 echo  "*/5 *  *   *    *      cd /var/www/$2/2016080806/shell/synchronization/order/; /usr/bin/php syncOrderTracking.php" >> Magentocron
 crontab  Magentocron
 rm Magentocron

echo "root="${11}"
TLS_CA_File=/etc/pki/tls/certs/ca-bundle.crt
mailhub=smtp.office365.com:587
rewriteDomain="${14}"
hostname=$1.wdnmczgigfhudmf4p1sa3we05e.dx.internal.cloudapp.net
UseTLS=YES
UseSTARTTLS=YES
AuthUser="${11}"
AuthPass="${12}"
AuthMethod=LOGIN
FromLineOverride=YES" > /etc/ssmtp/ssmtp.conf

echo "root:${11}:smtp.office365.com:587
		  noreply:${11}:smtp.office365.com:587" > /etc/ssmtp/revaliases
systemctl stop postfix
systemctl disable postfix
		  
alternatives --set mta "/usr/sbin/sendmail.ssmtp"
END=$(date +%s)
DIFFMin=$((((END - START )/60)))
DIFFSec=$((((END - START )%60)))

MailBody="
AutoSoEz Client Deployment Complete. Details given below<BR>
<BR>
FrontEnd:http://$1.$5/<BR>
AdminEnd:http://$1.$5/zpanel<BR>
IP for SSH admin: $IP<BR>
<BR>
$DIFFMin minutes and $DIFFSec seconds to deploy<BR>
Resource Group:  ${10}<BR>
Domain Name:  $1<BR>
Customer Name:  ${8}<BR>
Customer Tier:  ${9}<BR>
MySQL Password:   $4<BR>
VM Admin User:  ${6}<BR>
VM Admin Pass:  ${7}"

{
    echo "To: ${13}"
    echo "From: noreply <${11}>"
    echo "Subject: AutoSoEz Client Deployment Complete for customer $3"
	echo "Mime-Version: 1.0;"
    echo "Content-Type: text/html; charset=\"ISO-8859-1\""
	echo "Content-Transfer-Encoding: 7bit;"
    echo
    echo "$MailBody"
} | ssmtp ${13} 

echo "Mail Send. Install successfull">> /mylogs/text.txt
chmod -R 777 /var/www/"$2"/2016080806/shell/synchronization
echo -n "user_id=${8};pmp2_url=http://gcommercepmp2.cloudapp.net/" >/var/www/"$2"/2016080806/app/etc/cfg/client_info.conf
chmod 777 /var/www/"$2"/2016080806/app/etc/cfg/client_info.conf
rm -rf /var/www/"$2"/2016080806/var/cache/*
