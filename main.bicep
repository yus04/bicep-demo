@description('Username for the Virtual Machine.')
param adminUsername string

@description('Password for the Virtual Machine.')
@minLength(12)
@secure()
param adminPassword string

@description('Unique DNS Name for the Public IP used to access the Virtual Machine.')
param dnsLabelPrefix string = toLower('${vmName}-${uniqueString(resourceGroup().id, vmName)}')

@description('Name for the Public IP used to access the Virtual Machine.')
param publicIpName string = 'my-public-ip'

@description('Allocation method for the Public IP used to access the Virtual Machine.')
@allowed([
  'Dynamic'
  'Static'
])
param publicIPAllocationMethod string = 'Dynamic'

@description('SKU for the Public IP used to access the Virtual Machine.')
@allowed([
  'Basic'
  'Standard'
])
param publicIpSku string = 'Basic'

@description('The Windows version for the VM. This will pick a fully patched image of this given Windows version.')
@allowed([
  '2016-datacenter-gensecond'
  '2016-datacenter-server-core-g2'
  '2016-datacenter-server-core-smalldisk-g2'
  '2016-datacenter-smalldisk-g2'
  '2016-datacenter-with-containers-g2'
  '2016-datacenter-zhcn-g2'
  '2019-datacenter-core-g2'
  '2019-datacenter-core-smalldisk-g2'
  '2019-datacenter-core-with-containers-g2'
  '2019-datacenter-core-with-containers-smalldisk-g2'
  '2019-datacenter-gensecond'
  '2019-datacenter-smalldisk-g2'
  '2019-datacenter-with-containers-g2'
  '2019-datacenter-with-containers-smalldisk-g2'
  '2019-datacenter-zhcn-g2'
  '2022-datacenter-azure-edition'
  '2022-datacenter-azure-edition-core'
  '2022-datacenter-azure-edition-core-smalldisk'
  '2022-datacenter-azure-edition-smalldisk'
  '2022-datacenter-core-g2'
  '2022-datacenter-core-smalldisk-g2'
  '2022-datacenter-g2'
  '2022-datacenter-smalldisk-g2'
])
param OSVersion string = '2022-datacenter-azure-edition'

@description('Size of the virtual machine.')
param vmSize string = 'Standard_D2s_v5'

@description('Location for all resources.')
param location string = resourceGroup().location

@description('Name of the virtual machine.')
param vmName string = 'simple-vm'

@description('Security Type of the Virtual Machine.')
@allowed([
  'Standard'
  'TrustedLaunch'
])
param securityType string = 'TrustedLaunch'

var storageAccountName = 'sample-storage-account-${uniqueString(resourceGroup().id)}'
var nicName = 'my-vmnic'
var addressPrefix = '10.0.0.0/16'
var subnetName = 'Subnet'
var subnetPrefix = '10.0.0.0/24'
var virtualNetworkName = 'my-vnet'
var networkSecurityGroupName = 'default-neg'
var securityProfileJson = {
  uefiSettings: {
    secureBootEnabled: true
    vTpmEnabled: true
  }
  securityType: securityType
}

module storageAccount 'storage-account.bicep' = {
  name: 'storageAccount'
  params: {
    storageAccountName: storageAccountName
    location: location
  }
}

module publicIp 'pip.bicep' = {
  name: 'publicIp'
  params: {
    publicIpName: publicIpName
    location: location
    publicIPAllocationMethod: publicIPAllocationMethod
    dnsLabelPrefix: dnsLabelPrefix
    publicIpSku: publicIpSku
  }
}

module networkSecurityGroup 'nsg.bicep' = {
  name: 'networkSecurityGroup'
  params: {
    networkSecurityGroupName: networkSecurityGroupName
    location: location
  }
}

module virtualNetwork 'v-net.bicep' = {
  name: 'virtualNetwork'
  params: {
    virtualNetworkName: virtualNetworkName
    location: location
    addressPrefix: addressPrefix
    subnetName: subnetName
    subnetPrefix: subnetPrefix
    networkSecurityGroupId: networkSecurityGroup.outputs.id
  }
}

module nic 'nic.bicep' = {
  name: 'nic'
  params: {
    nicName: nicName
    location: location
    virtualNetworkName: virtualNetworkName
    subnetName: subnetName
    publicIpId: publicIp.outputs.id
  }
}

module virtualMachine 'vm.bicep' = {
  name: 'virtualMachine'
  params: {
    vmName: vmName
    location: location
    vmSize: vmSize
    adminUsername: adminUsername
    adminPassword: adminPassword
    OSVersion: OSVersion
    nicId: nic.outputs.id
    storageAccountName: storageAccount.outputs.name
    securityType: securityType
    securityProfileJson: securityProfileJson
  }
}
