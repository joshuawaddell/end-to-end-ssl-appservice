// Parameters
//////////////////////////////////////////////////
@description('The name of the application gateway.')
param applicationGatewayName string

@description('The name of the application gateway public ip address.')
param applicationGatewayPublicIpAddressName string

@description('The resource id of the application gateway subnet')
param applicationGatewaySubnetId string

@description('The fqdn of app service 1.')
param appService1Fqdn string

@description('The host name of app service 1.')
param appService1HostName string

@description('The fqdn of app service 2.')
param appService2Fqdn string

@description('The host name of app service 2.')
param appService2HostName string

@description('The data of the ssl certificate (stored in keyvault.)')
@secure()
param certificateData string

@description('The password of the ssl certificate (stored in keyvault.)')
@secure()
param certificatePassword string

@description('The name of the ssl certificate (stored in keyvault).')
param certificateName string

@description('The location for all resources.')
param location string

@description('The resource id of the managed identity.')
param managedIdentityId string

// Resource - Public Ip Address - Application Gateway
//////////////////////////////////////////////////
resource applicationGatewayPublicIpAddress 'Microsoft.Network/publicIPAddresses@2022-01-01' = {
  name: applicationGatewayPublicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
  }
}

// Resource - Application Gateway
//////////////////////////////////////////////////
resource applicationGateway 'Microsoft.Network/applicationGateways@2022-01-01' = {
  name: applicationGatewayName
  location: location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 1
    }
    enableHttp2: false
    sslCertificates: [
      {
        name: certificateName
        properties: {
          data: certificateData
          password: certificatePassword
        }
      }
    ]
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIPConfig'
        properties: {
          subnet: {
            id: applicationGatewaySubnetId
          }
        }
      }
    ]
    frontendIPConfigurations: [
      {
        name: 'frontendIpConfiguration'
        properties: {
          publicIPAddress: {
            id: applicationGatewayPublicIpAddress.id
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'backendPool-${appService1HostName}'
        properties: {
          backendAddresses: [
            {
              fqdn: appService1Fqdn
            }
          ]
        }
      }
      {
        name: 'backendPool-${appService2HostName}'
        properties: {
          backendAddresses: [
            {
              fqdn: appService2Fqdn
            }
          ]
        }
      }
    ]
    backendHttpSettingsCollection: [  
      {
        name: 'httpSetting-${appService1HostName}'
        properties: {
          cookieBasedAffinity: 'Disabled'                    
          requestTimeout: 20
          pickHostNameFromBackendAddress: true
          port: 443
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'healthProbe-${appService1HostName}')
          }
          protocol: 'Https'
        }
      }
      {
        name: 'httpSetting-${appService2HostName}'
        properties: {
          cookieBasedAffinity: 'Disabled'                    
          requestTimeout: 20
          pickHostNameFromBackendAddress: true
          port: 443
          probe: {
            id: resourceId('Microsoft.Network/applicationGateways/probes', applicationGatewayName, 'healthProbe-${appService2HostName}')
          }
          protocol: 'Https'
        }
      }
    ]    
    httpListeners: [
      {
        name: 'listener-${appService1HostName}-http'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          hostName: appService1HostName
          requireServerNameIndication: false
        }
      }
      {
        name: 'listener-${appService1HostName}-https'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, certificateName)
          }
          hostName: appService1HostName
          requireServerNameIndication: false
        }
      }
      {
        name: 'listener-${appService2HostName}-http'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_80')
          }
          protocol: 'Http'
          hostName: appService2HostName
          requireServerNameIndication: false
        }
      }
      {
        name: 'listener-${appService2HostName}-https'
        properties: {
          frontendIPConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendIPConfigurations', applicationGatewayName, 'frontendIpConfiguration')
          }
          frontendPort: {
            id: resourceId('Microsoft.Network/applicationGateways/frontendPorts', applicationGatewayName, 'port_443')
          }
          protocol: 'Https'
          sslCertificate: {
            id: resourceId('Microsoft.Network/applicationGateways/sslCertificates', applicationGatewayName, certificateName)
          }
          hostName: appService2HostName
          requireServerNameIndication: false
        }
      }
    ]
    redirectConfigurations: [
      {
        name: 'redirectConfiguration-${appService1HostName}'
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-${appService1HostName}-https')
          }
        }
      }
      {
        name: 'redirectConfiguration-${appService2HostName}'
        properties: {
          redirectType: 'Permanent'
          targetListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-${appService2HostName}-https')
          }
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'routingRule-${appService1HostName}'
        properties: {
          ruleType: 'Basic'
          priority: 100
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-${appService1HostName}-https')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'backendpool-${appService1HostName}')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'httpSetting-${appService1HostName}')
          }
        }
      }
      {
        name: 'routingRule-${appService1HostName}-redirection'
        properties: {
          ruleType: 'Basic'
          priority: 200
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-${appService1HostName}-http')
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, 'redirectConfiguration-${appService1HostName}')
          }
        }
      }
      {
        name: 'routingRule-${appService2HostName}'
        properties: {
          ruleType: 'Basic'
          priority: 300
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-${appService2HostName}-https')
          }
          backendAddressPool: {
            id: resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'backendpool-${appService1HostName}')
          }
          backendHttpSettings: {
            id: resourceId('Microsoft.Network/applicationGateways/backendHttpSettingsCollection', applicationGatewayName, 'httpSetting-${appService2HostName}')
          }
        }
      }
      {
        name: 'routingRule-${appService2HostName}-redirection'
        properties: {
          ruleType: 'Basic'
          priority: 400
          httpListener: {
            id: resourceId('Microsoft.Network/applicationGateways/httpListeners', applicationGatewayName, 'listener-${appService2HostName}-http')
          }
          redirectConfiguration: {
            id: resourceId('Microsoft.Network/applicationGateways/redirectConfigurations', applicationGatewayName, 'redirectConfiguration-${appService2HostName}')
          }
        }
      }
    ]
    probes: [      
      {
        name: 'healthProbe-${appService1HostName}'
        properties: {
          interval: 30
          match: {
            statusCodes: [
              '200-399'
            ]
          }
          path: '/'
          pickHostNameFromBackendHttpSettings: true
          protocol: 'Https'
          timeout: 30
          unhealthyThreshold: 3          
        }
      }
      {
        name: 'healthProbe-${appService2HostName}'
        properties: {
          interval: 30
          match: {
            statusCodes: [
              '200-399'
            ]
          }
          path: '/'
          pickHostNameFromBackendHttpSettings: true
          protocol: 'Https'
          timeout: 30
          unhealthyThreshold: 3          
        }
      }
    ]
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentityId}': {}
    }
  }
}

// Outputs
//////////////////////////////////////////////////
output backendPoolId string = resourceId('Microsoft.Network/applicationGateways/backendAddressPools', applicationGatewayName, 'backendPool')
