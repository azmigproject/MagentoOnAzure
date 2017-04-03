## Deploy Magento On Azure

### Deployment of existing magento package
This will install an existing magento package in a VM.It is required to provide the required backup paths for moving the files. For this go to ExistingPackageDeployment folder and use the ARM template (template.json) provided there<BR>

[![Click to deploy template on Azure](http://azuredeploy.net/deploybutton.png "Click to deploy template on Azure")](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fazmigproject%2FMagentoOnAzure%2Fmaster%2FExistingPackageDeployment%2Ftemplate.json)  



### Check your deployment
Once the deployment succeed,go to the installedUrl given as output when ARM template installed magento successfully