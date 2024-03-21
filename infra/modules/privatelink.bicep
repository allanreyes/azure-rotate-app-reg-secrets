param location string
param storageAccountName string
param vnetId string
param privateEndpointSubnetId string
param storageAccountId string
param target string

var privateStorageDnsZoneName = 'privatelink.${target}.${environment().suffixes.storage}'
var privateEndpointStorageName = '${storageAccountName}-${target}-private-endpoint'

resource privateStorageDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateStorageDnsZoneName
  location: 'global'
}

resource privateStorageDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateStorageDnsZone
  name: '${privateStorageDnsZoneName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

resource privateEndpointStoragePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-05-01' = {
  parent: privateEndpointStorage
  name: 'PrivateDnsZoneGroup-${target}'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config'
        properties: {
          privateDnsZoneId: privateStorageDnsZone.id
        }
      }
    ]
  }
}

resource privateEndpointStorage 'Microsoft.Network/privateEndpoints@2022-05-01' = {
  name: privateEndpointStorageName
  location: location
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'MyStoragePrivateLinkConnection-${target}'
        properties: {
          privateLinkServiceId: storageAccountId
          groupIds: [
            target
          ]
        }
      }
    ]
  }
}
