locals {
  bastion_uks_name = "bastion-uks"
}

resource "azurerm_resource_group" "bastion-uks-rg" {
  name     = "${local.bastion_uks_name}-rg"
  location = "UK South"

  tags = local.common_tags
}

resource "azurerm_virtual_network" "bastion-uks-vnet" {
  name                = "bastion-uks-vnet"
  location            = azurerm_resource_group.bastion-uks-rg.location
  resource_group_name = azurerm_resource_group.bastion-uks-rg.name
  address_space       = [local.address_space.spoke_bastion_uks.vnet]

  tags = local.common_tags
}

# hub connection instead of peering
resource "azurerm_virtual_hub_connection" "bastion-uks-vnet-vhub-connection" {
  name                      = "bastion-uks-vnet-vhub-connection"
  virtual_hub_id            = azurerm_virtual_hub.vhub-uks.id
  remote_virtual_network_id = azurerm_virtual_network.bastion-uks-vnet.id
}

resource "azurerm_subnet" "bastion-uks-snet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.bastion-uks-rg.name
  virtual_network_name = azurerm_virtual_network.bastion-uks-vnet.name
  address_prefixes     = [local.address_space.spoke_bastion_uks.bastion_subnet]
}

resource "azurerm_public_ip" "bastion-uks-pip" {
  name                = "${local.bastion_uks_name}-pip"
  location            = azurerm_resource_group.bastion-uks-rg.location
  resource_group_name = azurerm_resource_group.bastion-uks-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Must use Standard SKU to be able to use ip connect and communicate via peering.
# connect via ip: https://learn.microsoft.com/en-us/azure/bastion/connect-ip-address
# vwan requirements: https://learn.microsoft.com/en-us/azure/bastion/bastion-faq#vwan
resource "azurerm_bastion_host" "bastion-uks" {
  name                = local.bastion_uks_name
  location            = azurerm_resource_group.bastion-uks-rg.location
  resource_group_name = azurerm_resource_group.bastion-uks-rg.name
  sku                 = "Standard"
  ip_connect_enabled  = true

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion-uks-snet.id
    public_ip_address_id = azurerm_public_ip.bastion-uks-pip.id
  }
}