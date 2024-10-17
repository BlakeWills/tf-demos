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

# hub connection instead of peering
resource "azurerm_virtual_hub_connection" "spoke-two-uks-vnet-vhub-connection" {
  name                      = "spoke-two-uks-vnet-vhub-connection"
  virtual_hub_id            = azurerm_virtual_hub.vhub-uks.id
  remote_virtual_network_id = azurerm_virtual_network.spoke-two-uks-vnet.id
}

module "spoke-two-vm" {
  source = "../../modules/virtual-machine-linux"

  name            = "spoke-two-uks-vm"
  resource_group  = azurerm_resource_group.spoke-two-uks-rg
  virtual_network = azurerm_virtual_network.spoke-two-uks-vnet

  admin_username = var.vm_admin_username
  admin_password = var.vm_admin_password

  subnet_config = {
    address_prefixes = [local.address_space.spoke_two_uks.vm_subnet]
  }

  tags = local.common_tags
}