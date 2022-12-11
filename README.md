# Purpose

Test that a sas token for anonymous upload can be generated even if caller IP is not in the allow list.

# Deploy the infrastructure and test

```powershell
$subscription = "My Subscription"
$rgName = "frbar-stg-sastoken"
$envName = "fb08"
$location = "West Europe"

$ip = (Invoke-RestMethod http://ipinfo.io/json).ip

az login
az account set --subscription $subscription
az group create --name $rgName --location $location
az deployment group create --resource-group $rgName --template-file infra.bicep --mode complete --parameters envName=$envName

$key = az storage account keys list --account-name "$($envName)stg" --query [0].value -otsv

$sas = az storage container generate-sas --account-name "$($envName)stg" --expiry 2030-01-01 --name cont1 --permissions dlrw --account-key $key 

# upload should fail
az storage blob upload --account-name "$($envName)stg" --container-name 'cont1' --file test.txt --sas-token $sas --overwrite

az deployment group create --resource-group $rgName --template-file infra.bicep --mode complete --parameters envName=$envName myIp=$ip 

start-sleep -seconds 60

# upload should succeed
az storage blob upload --account-name "$($envName)stg" --container-name 'cont1' --file test.txt --sas-token $sas --overwrite

```

# Tear down

```powershell
az group delete --name $rgName
```


