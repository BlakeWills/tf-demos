resource "azurerm_resource_group" "hub-rg-uks" {
  name     = "hub-rg"
  location = "UK South"

  tags = local.common_tags
}

resource "azurerm_virtual_network" "hub-vnet-uks" {
  name                = "hub-vnet-uks"
  location            = azurerm_resource_group.hub-rg-uks.location
  resource_group_name = azurerm_resource_group.hub-rg-uks.name
  address_space       = [local.address_space.hub_uks.vnet]

  tags = local.common_tags
}