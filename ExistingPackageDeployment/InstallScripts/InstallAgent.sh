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
apt-get  -y install libunwind8 libunwind8-dev gettext libicu-dev liblttng-ust-dev libcurl4-openssl-dev libssl-dev uuid-dev unzip
apt-get update
apt-get install -y python-software-properties debconf-utils
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" |  debconf-set-selections
apt-get install -y oracle-java8-installer

wget "https://github.com/Microsoft/vsts-agent/releases/download/v2.120.1/vsts-agent-ubuntu.14.04-x64-2.120.1.tar.gz" -P /home/$3  -q

MgDir=$( find /var/www/ -type d -name "2016080806") 

 chmod 755 -R  "$MgDir/app"
 chmod 755 -R  "$MgDir/js"
 chmod 755 -R  "$MgDir/shell"
 chmod 755 -R  "$MgDir/skin"

mkdir "/mgbackup"
mkdir myagent && cd myagent
su -c  "sudo tar zxvf /home/$3/vsts-agent-ubuntu.14.04-x64-2.120.1.tar.gz
        ./config.sh --unattended --acceptteeeula --url \"$6\" --auth PAT --token \"$1\" --pool \"$2\" --agent \"$4\" --work \"$5\" " "$3"

echo "*  *  *   *    *      /myagent/bin/Agent.Listener run \$\* & > /myagent/log.txt " >>/etc/crontab
crontab -l > Magentocron
echo "*  *  *   *    *      /myagent/bin/Agent.Listener run \$\* & > /myagent/log.txt " >>Magentocron
crontab  Magentocron
rm Magentocron

shutdown -r +1 &
exit 0

