## Deploy Magento On Azure

### Deployment of new magento package
this will install a new magento2 package in a VM. For this go to NewPackageDeployment folder and use the ARM template (template.json) provided there<BR>

[![Click to deploy template on Azure](http://azuredeploy.net/deploybutton.png "Click to deploy template on Azure")](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazmigproject%2FMagentoOnAzure%2Fmaster%2FNewPackageDeployment%2Ftemplate.json)  


### Deployment of existing magento package
this will install an existing magento package in a VM whose backup paths are provided. For this go to ExistingPackageDeployment folder and use the ARM template (template.json) provided there<BR>

[![Click to deploy template on Azure](http://azuredeploy.net/deploybutton.png "Click to deploy template on Azure")](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazmigproject%2FMagentoOnAzure%2Fmaster%2FExistingPackageDeployment%2Ftemplate.json)  



### Check your deployment
Once the deployment succeed,go to the installedUrl given as output when ARM template installed magento successfully