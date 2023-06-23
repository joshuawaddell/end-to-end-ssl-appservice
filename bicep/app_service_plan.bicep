// Parmaters
//////////////////////////////////////////////////
@description('Parameter for location of the resource.')
param location string

@description('The name of the App Service Plan')
param appServicePlanName string

@description('The Sku of the App Service Plan.')
param appServicePlanSku string

@description('The capacity value of the App Service Plan.')
param appServicePlanInstanceCount int

// Resource - App Service Plan
//////////////////////////////////////////////////
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    name: appServicePlanSku
    capacity: appServicePlanInstanceCount
  }
  properties: {
    reserved: true
  }
}

// Outputs
//////////////////////////////////////////////////
output appServicePlanId string = appServicePlan.id
