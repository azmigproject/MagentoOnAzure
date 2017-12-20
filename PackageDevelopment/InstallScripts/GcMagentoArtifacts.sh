#!/bin/bash
#
#
# Param info coming from InstallMagentoBlank and InstallMagentoBlankCentOS file
# $2 -  Folder name && DatabaseName
# $8 -  MagentoFileBackup
# $9 -  MagentoDBBackup
# $11 - Magento Media Folder backup
# $12 - Magento Init Folder backup
# $13 - Magento Var Folder backup
# $27th parameter is magento New Folders Backup file name for listing new folders that need to be replaced";

# Param info in Artifacts 
# $1 - Folder name && DatabaseName
# $2 - MagentoFileBackup
# $3 - MagentoDBBackup
# $4 - Magento Media Folder backup
# $5 - Magento Init Folder backup
# $6 - Magento Var Folder backup
# $7 - magento New Folders Backup file name for listing new folders that need to be replaced

set -x
#set -xeuo pipefail to check if root user 

if [[ $(id -u) -ne 0 ]] ; then
    echo "Must be run as root"
    exit 1
fi

#First create the folder where tar file will be downloaded
mkdir /MagentoBK

#download magento media folder backup
echo "Start downloading magento media folder backup files">> /mylogs/text.txt
wget "${4}" -P /MagentoBK  -q
MagentoMediaBKFile=${4##*/}
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

#download magento latest folders
wget "${7}" -P /MagentoBK -q
MGNewFolderFile=${7##*/}
echo "Downloaded magento folder backup files. MGNewFolderFile=$MGNewFolderFile">> /mylogs/text.txt
chmod -R 777 /MagentoBK
mkdir /MagentoBK/NewFolder
tar -xvf /MagentoBK/"$MGNewFolderFile" -C /MagentoBK/NewFolder
echo "unzip magento backup files
	Start downloading magento init folder backup files">> /mylogs/text.txt

#remove the folders from magento installation and copy the new folder their

rm -rf /var/www/"$1"/"2016080806/app"
rm -rf /var/www/"$1"/"2016080806/js"
rm -rf /var/www/"$1"/"2016080806/shell"
rm -rf /var/www/"$1"/"2016080806/skin"
rm -rf /var/www/"$1"/"2016080806/var"

mv  /MagentoBK/NewFolder/magento_scripts_folders/2016080806/app  /var/www/"$1"/"2016080806"/
mv  /MagentoBK/NewFolder/magento_scripts_folders/2016080806/js  /var/www/"$1"/"2016080806"/
mv  /MagentoBK/NewFolder/magento_scripts_folders/2016080806/shell  /var/www/"$1"/"2016080806"/
mv  /MagentoBK/NewFolder/magento_scripts_folders/2016080806/skin  /var/www/"$1"/"2016080806"/
mv  /MagentoBK/NewFolder/magento_scripts_folders/2016080806/var  /var/www/"$1"/"2016080806"/

#download magento init folder backup
wget "${5}" -P /MagentoBK -q
MagentoInitBKFile=${5##*/}
echo "Downloaded magento init folder backup files. MagentoInitBKFile=$MagentoInitBKFile">> /mylogs/text.txt
chmod -R 777 /MagentoBK
tar -xvf /MagentoBK/"$MagentoInitBKFile" -C /var/www/"$1"
rm -rf /MagentoBK/"$MagentoInitBKFile"
echo "unzip magento init folder
	  Start downloading magento var folder backup files">> /mylogs/text.txt

#download magento var folder backup
wget "${6}" -P /MagentoBK -q
MagentoVarBKFile=${6##*/}
echo "Downloaded magento var folder backup files. MagentoVarBKFile=$MagentoVarBKFile">> /mylogs/text.txt
chmod -R 777 /MagentoBK
tar -xvf /MagentoBK/"$MagentoVarBKFile" -C /var/www/"$1"
rm -rf /MagentoBK/"$MagentoVarBKFile"
echo "Unzip magento var folder
	Start downloading mangeto db backup files">> /mylogs/text.txt

#download magento DB backup
wget "$3"  -P  /MagentoBK -q
MagentoDBBKFile=${3##*/}
chmod -R 777 /MagentoBK
echo "End downloading mangeto db backup files. MagentoDBBKFile=$MagentoDBBKFile">> /mylogs/text.txt

#Uninstall DB backup
mkdir /MagentoBK/DB
tar -xvf /MagentoBK/"$MagentoDBBKFile" -C /MagentoBK/DB
chmod -R 777 /MagentoBK/DB
