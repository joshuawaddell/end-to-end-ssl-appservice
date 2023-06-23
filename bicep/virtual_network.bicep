// Parameters
//////////////////////////////////////////////////
@description('The name of the application gateway subnet.')
param applicationGatewaySubnetName string

@description('The address prefix of the application gateway subnet.')
param applicationGatewaySubnetPrefix string

@description('The location of all resources.')
param location string

@description('The name of the virtual network.')
param virtualNetworkName string

@description('The address prefix of the virtual network.')
param virtualNetworkPrefix string

// Resource - Virtual Network
//////////////////////////////////////////////////
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2022-01-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        virtualNetworkPrefix
      ]
    }
    subnets: [
      {
        name: applicationGatewaySubnetName
        properties: {
          addressPrefix: applicationGatewaySubnetPrefix
        }
      } 
    ]
  }
  resource applicationGatewaySubnet 'subnets' existing = {
    name: applicationGatewaySubnetName
  }
}

// Outputs
//////////////////////////////////////////////////
output virtualNetworkId string = virtualNetwork.id
output applicationGatewaySubnetId string = virtualNetwork::applicationGatewaySubnet.id
