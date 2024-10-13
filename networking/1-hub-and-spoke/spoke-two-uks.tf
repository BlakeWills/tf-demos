resource "azurerm_resource_group" "spoke-two-rg-uks" {
  name     = "spoke-two-rg"
  location = "UK South"

  tags = local.common_tags
}

resource "azurerm_virtual_network" "spoke-two-vnet-uks" {
  name                = "spoke-vnet-uks"
  location            = azurerm_resource_group.spoke-two-rg-uks.location
  resource_group_name = azurerm_resource_group.spoke-two-rg-uks.name
  address_space       = [local.address_space.spoke_two_uks.vnet]

  tags = local.common_tags
}

resource "azurerm_virtual_network_peering" "hub-uks-spoke-two-uks" {
  name                      = "hub-uks-spoke-two-uks"
  resource_group_name       = azurerm_resource_group.hub-rg-uks.name
  virtual_network_name      = azurerm_virtual_network.hub-vnet-uks.name
  remote_virtual_network_id = azurerm_virtual_network.spoke-two-vnet-uks.id
}

resource "azurerm_virtual_network_peering" "spoke-two-uks-hub-uks" {
  name                      = "spoke-two-uks-hub-uks"
  resource_group_name       = azurerm_resource_group.spoke-two-rg-uks.name
  virtual_network_name      = azurerm_virtual_network.spoke-two-vnet-uks.name
  remote_virtual_network_id = azurerm_virtual_network.hub-vnet-uks.id
}

module "spoke-two-vm" {
  source = "../../modules/virtual-machine-linux"

  name            = "spoke-two-uks-vm"
  resource_group  = azurerm_resource_group.spoke-two-rg-uks
  virtual_network = azurerm_virtual_network.spoke-two-vnet-uks

  admin_username = var.vm_admin_username
  admin_password = var.vm_admin_password

  subnet_config = {
    address_prefixes = [local.address_space.spoke_two_uks.vm_subnet]
  }

  tags = local.common_tags
}