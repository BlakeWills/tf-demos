locals {
  hub_uks_fw_name = "hub-uks-fw"
}

resource "azurerm_subnet" "hub-uks-firewall-subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub-rg-uks.name
  virtual_network_name = azurerm_virtual_network.hub-vnet-uks.name
  address_prefixes     = [local.address_space.hub_uks.firewall_subnet]
}

resource "azurerm_public_ip" "hub-uks-firewall-pip" {
  name                = "${local.hub_uks_fw_name}-pip"
  location            = azurerm_resource_group.hub-rg-uks.location
  resource_group_name = azurerm_resource_group.hub-rg-uks.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "hub-uks-firewall" {
  name                = local.hub_uks_fw_name
  location            = azurerm_resource_group.hub-rg-uks.location
  resource_group_name = azurerm_resource_group.hub-rg-uks.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub-uks-firewall-subnet.id
    public_ip_address_id = azurerm_public_ip.hub-uks-firewall-pip.id
  }
}