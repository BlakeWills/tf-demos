resource "azurerm_resource_group" "spoke-two-uks-rg" {
  name     = "spoke-two-uks-rg"
  location = "UK South"

  tags = local.common_tags
}

resource "azurerm_virtual_network" "spoke-two-uks-vnet" {
  name                = "spoke-two-uks-vnet"
  location            = azurerm_resource_group.spoke-two-uks-rg.location
  resource_group_name = azurerm_resource_group.spoke-two-uks-rg.name
  address_space       = [local.address_space.spoke_two_uks.vnet]

  tags = local.common_tags
}

resource "azurerm_virtual_network_peering" "hub-uks-spoke-two-uks" {
  name                      = "hub-uks-spoke-two-uks"
  resource_group_name       = azurerm_resource_group.hub-uks-rg.name
  virtual_network_name      = azurerm_virtual_network.hub-uks-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke-two-uks-vnet.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "spoke-two-uks-hub-uks" {
  name                      = "spoke-two-uks-hub-uks"
  resource_group_name       = azurerm_resource_group.spoke-two-uks-rg.name
  virtual_network_name      = azurerm_virtual_network.spoke-two-uks-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub-uks-vnet.id
  allow_forwarded_traffic   = true
}

module "spoke-two-vm" {
  source = "../../modules/virtual-machine-linux"

  name            = "spoke-two-uks-vm"
  resource_group  = azurerm_resource_group.spoke-two-uks-rg
  virtual_network = azurerm_virtual_network.spoke-two-uks-vnet

  admin_username = var.vm_admin_username
  admin_password = var.vm_admin_password

  subnet_config = {
    route_table      = azurerm_route_table.hub-uks-firewall-rt
    address_prefixes = [local.address_space.spoke_two_uks.vm_subnet]
  }

  tags = local.common_tags
}