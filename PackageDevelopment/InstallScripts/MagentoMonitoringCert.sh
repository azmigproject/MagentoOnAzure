#!/bin/bash
#
#
# Param info coming from InstallMagentoBlank file
# $1 -Domain name
# $2 -Folder name && DatabaseName
# $6 -HOSTNAME
# $20- parameter is Monitoring tool files

# Param used in these file
# $1 -Domain name
# $2 -Folder name && DatabaseName
# $3 -HOSTNAME
# $4- parameter is Monitoring tool files

#section for installing certbot SSL
apt-get -y -qq install software-properties-common
add-apt-repository -y  ppa:certbot/certbot
apt-get -y -qq update
apt-get -y -qq install python-certbot-apache 

if [ "${3/'azure.com'}" = "$3" ] ; then
  certbot certonly --webroot -w /var/www/"$2"/2016080806/ -d "$1.$3"  --agree-tos  --email azuredeployments@gcommerceinc.com -n
else
  certbot certonly --webroot -w /var/www/"$2"/2016080806/ -d "$1.$3"  --agree-tos  --email azuredeployments@gcommerceinc.com -n --test-cert 
fi
tempvar="$1.$3"
certbot --apache -d "$tempvar" --no-redirect --agree-tos  --email azuredeployments@gcommerceinc.com  -n  
echo "certbot renew -n --agree-tos --email azuredeployments@gcommerceinc.com --post-hook 'service apache2 restart'"> /etc/cron.daily/certbotcron
chmod 777 /etc/cron.daily/certbotcron

#Install Monitoring tools
apt-get -y -qq install xinetd
wget "${4}" -P /MagentoBK -q
unzip /MagentoBK/MonitoringAgentFiles -d /MagentoBK/
mv  /MagentoBK/check_mk_agent  /usr/bin  
chmod +x /usr/bin/check_mk_agent
mv  /MagentoBK/waitmax /usr/bin  
chmod +x  /usr/bin/waitmax 
mv /MagentoBK/check_mk /etc/xinetd.d
/etc/init.d/xinetd restart
rm -rf /MagentoBK
#end Monitoring tools