resource "azurerm_resource_group" "hub-uks-rg" {
  name     = "hub-uks-rg"
  location = "UK South"

  tags = local.common_tags
}

resource "azurerm_virtual_wan" "vwan" {
  name                = "vwan"
  resource_group_name = azurerm_resource_group.hub-uks-rg.name
  location            = azurerm_resource_group.hub-uks-rg.location
}

resource "azurerm_virtual_hub" "vhub-uks" {
  name                = "vhub-uks"
  resource_group_name = azurerm_resource_group.hub-uks-rg.name
  location            = azurerm_resource_group.hub-uks-rg.location
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  address_prefix      = local.address_space.hub_uks.vnet
}