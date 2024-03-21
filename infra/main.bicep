targetScope = 'subscription'

param resourceGroupName string
param location string
param vnetAddressPrefix string
param appSubnetAddressPrefix string
param storageSubnetAddressPrefix string

var suffix = uniqueString(rg.id)
var functionAppName = 'func-rotate-app-reg-secret-${suffix}'
var storageAccountName = 'stor${suffix}'
var targets = [
  'table'
  'blob'
  'queue'
  'file'
]

resource rg 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: resourceGroupName
  location: location
}

module vnet 'modules/vnet.bicep' = {
  scope: rg
  name: 'vnet'
  params: {
    location: location
    vnetName: 'vnet-${suffix}'
    vnetAddressPrefix: vnetAddressPrefix
    appSubnetAddressPrefix: appSubnetAddressPrefix
    appSubnetName: 'app-snet-${suffix}'
    storageSubnetAddressPrefix: storageSubnetAddressPrefix
    storageSubnetName: 'storage-snet-${suffix}'
  }
}

module privateLink 'modules/privateLink.bicep' = [for target in targets: {
  name: 'privateLink${target}'
  scope: rg
  params: {
    location: location
    vnetId: vnet.outputs.vnetId
    privateEndpointSubnetId: vnet.outputs.storageSubnetId
    storageAccountId: storageAccount.outputs.storageAccountId
    storageAccountName: storageAccount.outputs.storageAccountName
    target: target
  }
}]

module storageAccount 'modules/storageAccount.bicep' = {
  scope: rg
  name: 'storageAccount'
  params: {
    location: location
    storageAccountName: storageAccountName
    subnetId: vnet.outputs.storageSubnetId
  }
}

module appInsights 'modules/appInsights.bicep' = {
  scope: rg
  name: 'appInsights'
  params: {
    location: location
    appInsightsName: 'appinsights-${suffix}'
  }
}

module appServicePlan 'modules/appServicePlan.bicep' = {
  scope: rg
  name: 'appServicePlan'
  params: {
    location: location
    appServicePlanName: 'asp-${suffix}'
  }
}

module functionapp 'modules/functionapp.bicep' = {
  scope: rg
  name: functionAppName
  params: {
    applicationInsightInstrumentationKey: appInsights.outputs.instrumentationKey
    functionAppName: '${functionAppName}-${uniqueString(rg.id)}'
    location: location
    storageAccountName: storageAccountName
    appServicePlanId: appServicePlan.outputs.appServicePlanId
    snetId: vnet.outputs.appSubnetId
  }
}

output functionAppName string = functionapp.outputs.functionAppName
