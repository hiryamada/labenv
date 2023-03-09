param location string = 'japaneast'

param networkInterfaceName string = 'nic-${uniqueString(resourceGroup().name)}'

param virtualNetworkName string = 'vnet-${uniqueString(resourceGroup().name)}'
param subnetName string = 'subnet1'
param publicIpAddressName string = 'ip-${uniqueString(resourceGroup().name)}'
param virtualMachineName string = 'labvm-${uniqueString(resourceGroup().name)}'
param virtualMachineComputerName string = 'labvm'

param osDiskType string = 'Premium_LRS'
param virtualMachineSize string = 'Standard_D2s_v5'
param adminUsername string = 'azureuser'

@secure()
param adminPassword string

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: 'nsg-${uniqueString(resourceGroup().name)}'
  location: location
  properties: {
    securityRules: [
      {
        id: 'RDP'
        name: 'RDP'
        properties: {
          priority: 1000
          protocol: 'TCP'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
    ]
  }
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-09-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [ '10.0.0.0/16' ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.0.0/24'
          networkSecurityGroup: { id: networkSecurityGroup.id }
        }
      }
    ]
  }
  resource subnet1 'subnets' existing = {
    name: subnetName
  }
}

resource publicIpAddress 'Microsoft.Network/publicIPAddresses@2022-07-01' = {
  name: publicIpAddressName
  location: location
  sku: { name: 'Standard' }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource networkInterface 'Microsoft.Network/networkInterfaces@2018-10-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: { id: virtualNetwork::subnet1.id }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: { id: publicIpAddress.id }
        }
      }
    ]
  }
}

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-11-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'fromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-Datacenter'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        { id: networkInterface.id }
      ]
    }
    osProfile: {
      computerName: virtualMachineComputerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
        patchSettings: {
          patchMode: 'AutomaticByPlatform'
        }
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}

output ip string = publicIpAddress.properties.ipAddress
