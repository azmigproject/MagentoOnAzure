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

# Param used in these file
# $1 - Domain name
# $2 - Magento user name
# $3 - Magento SQL Password
# $4 - HOSTNAME
# $5 - VM USERName
# $6 - VM PAssword
# $7 - CustomerID
# $8 - Customertier
# $9 - Resourcegroup
# $10 - Folder name && DatabaseName
#
#cron Tab Update
echo "*/10 *  *   *    *      cd /var/www/${10}/2016080806/shell/synchronization/; /usr/bin/php main.php > /var/www/${10}/2016080806/var/log/main_cron.log
*/15 *  *   *    *      cd /var/www/${10}/2016080806/shell/synchronization/vehicle/; python va_controller.py > /var/www/${10}/2016080806/var/log/va_controller_cron.log
" >>/etc/crontab

sed -i 's,/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin,/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/var/www/$2/2016080806/shell/synchronization:/usr/bin,g' /etc/crontab

 crontab -l > Magentocron
 echo  "*/10   *   *    *   *   cd /var/www/${10}/2016080806/shell/synchronization/; /usr/bin/php main.php > /var/www/${10}/2016080806/var/log/main_cron.log" >> Magentocron
 echo  "*/15   *   *    *   *   cd /var/www/${10}/2016080806/shell/synchronization/vehicle/; python va_controller.py > /var/www/${10}/2016080806/var/log/va_controller_cron.log" >> Magentocron
 crontab  Magentocron
 rm Magentocron

#MailSendingVariables
#Live
#SenderEmail="information-prod@gcommerceinc.com"
#SenderPWD="AutoGComm1!"
#RecieverEmail="azuredeployments@gcommerceinc.com"
#SenderDomain="gcommerceinc.com"

#Demo
SenderEmail="akash.jaisawal@maarglabs.com"
SenderPWD="Hackerakash@90"
RecieverEmail="rupesh.nagar@maarglabs.com"
SenderDomain="maarglabs.com"

mv /etc/ssmtp/ssmtp.conf /etc/ssmtp/ssmtp.conf.sample

echo  "# Config file for sSMTP sendmail
#
# The person who gets all mail for userids < 1000
# Make this empty to disable rewriting.
#root=postmaster
root=$SenderEmail

# The place where the mail goes. The actual machine name is required no
# MX records are consulted. Commonly mailhosts are named mail.domain.com
# mailhub=mail
mailhub=smtp.office365.com:587
AuthUser=$SenderEmail
AuthPass=$SenderPWD
UseTLS=YES
UseSTARTTLS=YES
TLS_CA_File=/etc/pki/tls/certs/ca-bundle.crt
# Where will the mail seem to come from?
#rewriteDomain=
rewriteDomain=$SenderDomain

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
root:$SenderEmail:smtp.office365.com:587
noreply:$SenderEmail:smtp.office365.com:587
" > /etc/ssmtp/revaliases
END="$(date +%s)"
DIFFMin="$((((END - START )/60)))"
DIFFSec="$((((END - START )%60)))"

MailBody="
AutoSoEz Client Deployment Complete. Details given below<BR>
<BR>
FrontEnd:http://$1.$4/<BR>
AdminEnd:http://$1.$4/zpanel<BR>
IP for SSH admin: $IP<BR>
<BR>
$DIFFMin minutes and $DIFFSec seconds to deploy<BR>
Resource Group:  ${9}<BR>
Domain Name:  $1<BR>
Customer Name:  ${7}<BR>
Customer Tier:  ${8}<BR>
MySQL Password:   $3<BR>
VM Admin User:  ${5}<BR>
VM Admin Pass:  ${6}"

{
    echo "To: $RecieverEmail"
    echo "From: noreply <$SenderEmail>"
    echo "Subject: AutoSoEz Client Deployment Complete for customer $2 on CentOS Platform"
	echo "Mime-Version: 1.0;"
    echo "Content-Type: text/html; charset=\"ISO-8859-1\""
	echo "Content-Transfer-Encoding: 7bit;"
    echo
    echo "$MailBody"

} | ssmtp "$RecieverEmail" 

echo "Mail Send. Install successfull">> /mylogs/text.txt

chmod -R 777 var/www/"${10}"/2016080806/shell/synchronization
echo -n "user_id=${7};pmp2_url=http://gcommercepmp2.cloudapp.net/" >/var/www/"${10}"/2016080806/app/etc/cfg/client_info.conf
chmod 777 /var/www/"${10}"/2016080806/app/etc/cfg/client_info.conf
