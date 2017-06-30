#!/bin/bash
#
#
# Param info coming from InstallMagentoBlank file
# $2  -Folder name && DatabaseName
# $8  -MagentoFileBackup
# $9 - MagentoDBBackup
# $11 -Magento Media Folder backup
# $12 -Magento Init Folder backup
# $13 -Magento Var Folder backup

# Param used in these file
# $1 -Folder name && DatabaseName
# $2 -MagentoFileBackup
# $3 -Magento Media Folder backup
# $4 -Magento Init Folder backup
# $5 -Magento Var Folder backup
# $6 -MagentoDBBackup

#First create the folder where tar file will be downloaded
mkdir /MagentoBK

#download magento media folder backup
echo "Start downloading magento media folder backup files">> /mylogs/text.txt
wget "${3}" -P /MagentoBK  -q
MagentoMediaBKFile=${3##*/}
echo "Downloaded magento media folder backup files. MagentoMediaBKFile=$MagentoMediaBKFile">> /mylogs/text.txt
chmod -R 777 /MagentoBK

#create directory where code will store
echo "Created required directory and Start downloading magento media folder backup files">> /mylogs/text.txt
mkdir /var/www/"$1"
unzip /MagentoBK/"$MagentoMediaBKFile" -d /var/www/"$1"
rm -rf /MagentoBK/"$MagentoMediaBKFile" 
echo "Completed downloaded for magento media folder backup files and remove the backup file
      Start downloading magento backup files">> /mylogs/text.txt

#download magento file backup
wget "$2" -P /MagentoBK -q
MagentoBKFile=${2##*/}
echo "Downloaded magento backup files. MagentoBKFile=$MagentoBKFile">> /mylogs/text.txt
chmod -R 777 /MagentoBK
tar -xvf /MagentoBK/"$MagentoBKFile" -C /var/www/"$1"
rm -rf /MagentoBK/"$MagentoBKFile"
echo "unzip magento backup files
	 Start downloading magento init folder backup files">> /mylogs/text.txt

#download magento init folder backup
wget "${4}" -P /MagentoBK -q
MagentoInitBKFile=${4##*/}
echo "Downloaded magento init folder backup files. MagentoInitBKFile=$MagentoInitBKFile">> /mylogs/text.txt
chmod -R 777 /MagentoBK
tar -xvf /MagentoBK/"$MagentoInitBKFile" -C /var/www/"$1"
rm -rf /MagentoBK/"$MagentoInitBKFile"
echo "unzip magento init folder
	  Start downloading magento var folder backup files">> /mylogs/text.txt

#download magento var folder backup
wget "${5}" -P /MagentoBK -q
MagentoVarBKFile=${5##*/}
echo "Downloaded magento var folder backup files. MagentoVarBKFile=$MagentoVarBKFile">> /mylogs/text.txt
chmod -R 777 /MagentoBK
tar -xvf /MagentoBK/"$MagentoVarBKFile" -C /var/www/"$1"
rm -rf /MagentoBK/"$MagentoVarBKFile"
echo "Unzip magento var folder
	Start downloading mangeto db backup files">> /mylogs/text.txt

#download magento DB backup
wget "$6"  -P  /MagentoBK -q
MagentoDBBKFile=${6##*/}
chmod -R 777 /MagentoBK
echo "End downloading mangeto db backup files. MagentoDBBKFile=$MagentoDBBKFile">> /mylogs/text.txt