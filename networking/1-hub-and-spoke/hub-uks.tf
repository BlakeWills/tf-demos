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