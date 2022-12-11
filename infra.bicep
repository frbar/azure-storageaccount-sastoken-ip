targetScope = 'resourceGroup'

param location string = resourceGroup().location
param envName string
param myIp string = ''

var ips = (myIp != '' ? [myIp] : [])

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: '${envName}stg'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {
    networkAcls: {
      defaultAction: 'Deny'
      ipRules: [for ip in ips: {
          value: ip
          action: 'Allow'
        }]
    }
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = {
  name: 'cont1'
  parent: blobService
}


