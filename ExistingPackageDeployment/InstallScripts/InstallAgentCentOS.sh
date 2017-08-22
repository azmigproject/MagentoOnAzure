#!/bin/bash
# Script to insert the packages required for installing  TFS Agent
set -x
#set -xeuo pipefail to check if root user 

if [[ $(id -u) -ne 0 ]] ; then
    echo "Must be run as root"
    exit 1
fi
if [ $# -lt 6 ]; then
     echo ""
        echo "Missing parameters.";
        echo "1st parameter is PAT token";
        echo "2nd parameter is Agent Pool Name";
        echo "3rd parameter is adminusername";
        echo "4th parameter is agentName";
		echo "5th parameter is  work Folder";
		echo "6th parameter is  TFS URL";
		#echo "Try this: magento-prepare.sh 2.0.7 mywebshop.com magento magento";
        echo "";
    exit 1
fi

sudo yum -y install libunwind.x86_64 icu deltarpm epel-release unzip libunwind gettext libcurl-devel openssl-devel zlib libicu-devel

yum -y update

wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
"http://download.oracle.com/otn-pub/java/jdk/8u144-b01/090f390dda5b47b9b721c7dfaa008135/jre-8u144-linux-x64.rpm"

sudo yum -y localinstall jre-8u144-linux-x64.rpm

wget "https://github.com/Microsoft/vsts-agent/releases/download/v2.120.2/vsts-agent-rhel.7.2-x64-2.120.2.tar.gz" -P /home/$3  -q

MgDir=$( find /var/www/ -type d -name "2016080806") 

 chmod 755 -R  "$MgDir/app"
 chmod 755 -R  "$MgDir/js"
 chmod 755 -R  "$MgDir/shell"
 chmod 755 -R  "$MgDir/skin"

mkdir "/mgbackup"
mkdir myagent && cd myagent
su -c  "sudo tar zxvf /home/$3/vsts-agent-rhel.7.2-x64-2.120.2.tar.gz" "$3"
su -c  "./config.sh --unattended --acceptteeeula --url \"$6\" --auth PAT --token \"$1\" --pool \"$2\" --agent \"$4\" --work \"$5\" " "$3"

echo "*  *  *   *    *      /myagent/bin/Agent.Listener run \$* & > /myagent/log.txt " >>/etc/crontab
crontab -l > Magentocron
echo "*  *  *   *    *      /myagent/bin/Agent.Listener run \$* & > /myagent/log.txt " >>Magentocron
crontab  Magentocron
rm Magentocron

shutdown -r +1 &
exit 0

