resource "azurerm_resource_group" "spoke-one-rg-uks" {
  name     = "spoke-one-rg"
  location = "UK South"

  tags = local.common_tags
}

resource "azurerm_virtual_network" "spoke-one-vnet-uks" {
  name                = "spoke-vnet-uks"
  location            = azurerm_resource_group.spoke-one-rg-uks.location
  resource_group_name = azurerm_resource_group.spoke-one-rg-uks.name
  address_space       = [local.address_space.spoke_one_uks.vnet]

  tags = local.common_tags
}


resource "azurerm_virtual_network_peering" "hub-uks-spoke-one-uks" {
  name                      = "hub-uks-spoke-one-uks"
  resource_group_name       = azurerm_resource_group.hub-rg-uks.name
  virtual_network_name      = azurerm_virtual_network.hub-vnet-uks.name
  remote_virtual_network_id = azurerm_virtual_network.spoke-one-vnet-uks.id
}

resource "azurerm_virtual_network_peering" "spoke-one-uks-hub-uks" {
  name                      = "spoke-one-uks-hub-uks"
  resource_group_name       = azurerm_resource_group.spoke-one-rg-uks.name
  virtual_network_name      = azurerm_virtual_network.spoke-one-vnet-uks.name
  remote_virtual_network_id = azurerm_virtual_network.hub-vnet-uks.id
}

module "spoke-one-vm" {
  source = "../../modules/virtual-machine-linux"

  name            = "spoke-one-uks-vm"
  resource_group  = azurerm_resource_group.spoke-one-rg-uks
  virtual_network = azurerm_virtual_network.spoke-one-vnet-uks

  admin_username = var.vm_admin_username
  admin_password = var.vm_admin_password

  subnet_config = {
    address_prefixes = [local.address_space.spoke_one_uks.vm_subnet]
  }

  tags = local.common_tags
}