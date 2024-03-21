param location string
param storageAccountName string
param subnetId string

resource functionStorageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    publicNetworkAccess: 'Enabled'
    allowBlobPublicAccess: false
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
      virtualNetworkRules: [
        {
          id: subnetId
          action: 'Allow'
        }
      ]
    }
  }
}

resource tableServices 'Microsoft.Storage/storageAccounts/tableServices@2022-09-01' = {
  name: 'default'
  parent: functionStorageAccount
}

resource anomalyTable 'Microsoft.Storage/storageAccounts/tableServices/tables@2022-05-01' = {
  name: 'appreg'
  parent: tableServices
}

output storageAccountId string = functionStorageAccount.id
output storageAccountName string = functionStorageAccount.name
