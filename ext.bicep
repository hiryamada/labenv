param location string = 'japaneast'
param virtualMachineName string = 'labvm-${uniqueString(resourceGroup().name)}'

resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-11-01' existing = {
  name: virtualMachineName
}

resource customScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2022-11-01' = {
  name: 'custom${uniqueString(resourceGroup().name)}'
  location: location
  parent: virtualMachine
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      fileUris: [
        'https://raw.githubusercontent.com/hiryamada/labvm/main/labvm.ps1'
      ]
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File labvm.ps1'
    }
    settings: {
      timestamp: 123
    }
  }
}
