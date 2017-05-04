## Deploy Magento On Azure

### Deployment of new magento package
This will install a new magento package in a VM. For this go to NewPackageDeployment folder and use the ARM template (template.json) provided there<BR>

[![Click to deploy template on Azure](http://azuredeploy.net/deploybutton.png "Click to deploy template on Azure")](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazmigproject%2FMagentoOnAzure%2Fmaster%2FNewPackageDeployment%2Ftemplate.json)  


### Deployment of existing magento package
This will install an existing magento package in a VM.It is required to provide the required backup paths for moving the files. For this go to ExistingPackageDeployment folder and use the ARM template (template.json) provided there<BR>

[![Click to deploy template on Azure](http://azuredeploy.net/deploybutton.png "Click to deploy template on Azure")](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazmigproject%2FMagentoOnAzure%2Fmaster%2FExistingPackageDeployment%2Ftemplate.json)  



### Check your deployment
The installedUrl output provided by the ARM template upon successful deployment can be used to verify the deployment.