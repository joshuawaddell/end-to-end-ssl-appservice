// Parmaters
//////////////////////////////////////////////////
@description('Parameter for location of the resource.')
param location string

@description('The name of App Service 1')
param appService1Name string

@description('The name of App Service 2')
param appService2Name string

@description('The App Service Plan Id. This value is passed in through the main.bicep file from an output.')
param appServicePlanId string

// Resource - App Service 1
//////////////////////////////////////////////////
resource appService1 'Microsoft.Web/sites@2022-03-01' = {
  name: appService1Name
  location: location
  kind: 'container'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/appsvc/staticsite:latest'
    }
  }
}

// Resource - App Service 
//////////////////////////////////////////////////
resource appService2 'Microsoft.Web/sites@2022-03-01' = {
  name: appService2Name
  location: location
  kind: 'container'
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|mcr.microsoft.com/appsvc/staticsite:latest'
    }
  }
}

// Outputs
//////////////////////////////////////////////////
output appService1Fqdn string = appService1.properties.defaultHostName
output appService2Fqdn string = appService2.properties.defaultHostName
