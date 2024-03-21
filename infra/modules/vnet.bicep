param vnetName string
param vnetAddressPrefix string
param appSubnetName string
param appSubnetAddressPrefix string
param storageSubnetName string
param storageSubnetAddressPrefix string
param location string

resource vnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: appSubnetName
        properties: {
          addressPrefix: appSubnetAddressPrefix
          delegations: [
            {
              name: 'Microsoft.Web/serverFarms'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: storageSubnetName
        properties: {
          addressPrefix: storageSubnetAddressPrefix
          serviceEndpoints: [
            {
              service: 'Microsoft.Storage'
            }
          ]
        }
      }
    ]
  }
}

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  name: appSubnetName
  parent: vnet
}

resource storageSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = {
  name: storageSubnetName
  parent: vnet
}

output vnetId string = vnet.id
output appSubnetId string = appSubnet.id
output storageSubnetId string = storageSubnet.id

