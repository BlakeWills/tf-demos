resource "azurerm_resource_group" "hub-uks-rg" {
  name     = "hub-uks-rg"
  location = "UK South"

  tags = local.common_tags
}

resource "azurerm_virtual_network" "hub-uks-vnet" {
  name                = "hub-uks-vnet"
  location            = azurerm_resource_group.hub-uks-rg.location
  resource_group_name = azurerm_resource_group.hub-uks-rg.name
  address_space       = [local.address_space.hub_uks.vnet]

  tags = local.common_tags
}

# Private DNS Zone for azurewebsites.net allows PE's to register private addresses for web apps
resource "azurerm_private_dns_zone" "hub-uks-web-pdnszone" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.hub-uks-rg.name
}

# Need to link to Private DNS Zone for to the hub vnet to allow for resources to resolve
resource "azurerm_private_dns_zone_virtual_network_link" "hub-uks-vnet-web-pl-link" {
  name = "hub-uks-vnet-web-pl-link"
  resource_group_name = azurerm_resource_group.hub-uks-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.hub-uks-web-pdnszone.name
  virtual_network_id = azurerm_virtual_network.hub-uks-vnet.id
  registration_enabled = false
}