// Parameters
//////////////////////////////////////////////////
@description('The password of the certificate.')
@secure()
param certificatePassword string

@description('The name of the custom domain.')
param domainName string

@description('The name of the key Vault.')
param keyVaultName string

@description('The location for all resources.')
param location string = resourceGroup().location

@description('The name of the managed identity.')
param managedIdentityName string

@description('The name of the resource group.')
param resourceGroupName string

// Variables
//////////////////////////////////////////////////
var applicationGatewayName = 'appGw-e2esslapp-01'
var applicationGatewayPublicIpAddressName = 'pip-e2esslapp-applicationgateway'
var applicationGatewaySubnetName = 'snet-e2esslapp-applicationgateway'
var applicationGatewaySubnetPrefix = '10.0.0.0/24'
var appService1HostName = 'appService1.${domainName}'
var appService1Name = 'appService1-${uniqueString(resourceGroup().id)}'
var appService2HostName = 'appService2.${domainName}'
var appService2Name = 'appService2-${uniqueString(resourceGroup().id)}'
var appServicePlanInstanceCount = 1
var appServicePlanName = 'plan-e2esslapp-01'
var appServicePlanSku = 'P1v3'
var virtualNetworkName = 'vnet-e2esslapp-01'
var virtualNetworkPrefix = '10.0.0.0/16'

// Existing Resources
//////////////////////////////////////////////////

// Existing Resource - Key Vault
//////////////////////////////////////////////////
resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' existing = {
  scope: resourceGroup(resourceGroupName)
  name: keyVaultName
}

// Existing Resource - Managed Identity
//////////////////////////////////////////////////
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  scope: resourceGroup(resourceGroupName)
  name: managedIdentityName
}

// Virtual Network Module
//////////////////////////////////////////////////
module virtualNetworkModule 'virtual_network.bicep' = {
  name: 'virtualNetworkDeployment'
  params: {
    applicationGatewaySubnetName: applicationGatewaySubnetName
    applicationGatewaySubnetPrefix: applicationGatewaySubnetPrefix
    location: location
    virtualNetworkName: virtualNetworkName
    virtualNetworkPrefix: virtualNetworkPrefix
  }
}

// App Service Plan Module
//////////////////////////////////////////////////
module appServicePlanModule 'app_service_plan.bicep' = {
  name: 'appServicePlanDeployment'
  params: {
    appServicePlanInstanceCount: appServicePlanInstanceCount
    appServicePlanName: appServicePlanName
    appServicePlanSku: appServicePlanSku
    location: location
  }
}

// App Service Module
//////////////////////////////////////////////////
module appServiceModule 'app_service.bicep' = {
  name: 'appServiceDeployment'
  params: {
    appService1Name: appService1Name
    appService2Name: appService2Name
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    location: location
  }
}

// Application Gateway Module
//////////////////////////////////////////////////
module applicationGatewayModule 'application_gateway.bicep' = {
  name: 'applicationGatewayDeployment'
  params: {
    applicationGatewayName: applicationGatewayName
    applicationGatewayPublicIpAddressName: applicationGatewayPublicIpAddressName
    applicationGatewaySubnetId: virtualNetworkModule.outputs.applicationGatewaySubnetId
    appService1Fqdn: appServiceModule.outputs.appService1Fqdn
    appService1HostName: appService1HostName
    appService2Fqdn: appServiceModule.outputs.appService2Fqdn
    appService2HostName: appService2HostName
    certificateData: keyVault.getSecret('certificate')
    certificateName: domainName
    certificatePassword: certificatePassword
    location: location
    managedIdentityId: managedIdentity.id
  }
}
