#!/bin/bash
#
#
# Param info coming from InstallMagentoBlank file
# $20- parameter is Monitoring tool files

# Param used in these file
# $1- parameter is Monitoring tool files

# Install Monitoring tools

wget "${1}" -P /MagentoBK -q
unzip /MagentoBK/MonitoringAgentFiles -d /MagentoBK/
mv  /MagentoBK/check_mk_agent  /usr/bin  
chmod +x /usr/bin/check_mk_agent
mv  /MagentoBK/waitmax /usr/bin  
chmod +x  /usr/bin/waitmax 
mv /MagentoBK/check_mk /etc/xinetd.d
/etc/init.d/xinetd restart
rm -rf /MagentoBK
#end Monitoring tools