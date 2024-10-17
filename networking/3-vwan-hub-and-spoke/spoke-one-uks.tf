resource "azurerm_resource_group" "spoke-one-uks-rg" {
  name     = "spoke-one-uks-rg"
  location = "UK South"

  tags = local.common_tags
}

resource "azurerm_virtual_network" "spoke-one-uks-vnet" {
  name                = "spoke-one-uks-vnet"
  location            = azurerm_resource_group.spoke-one-uks-rg.location
  resource_group_name = azurerm_resource_group.spoke-one-uks-rg.name
  address_space       = [local.address_space.spoke_one_uks.vnet]

  tags = local.common_tags
}

# hub connection instead of peering
resource "azurerm_virtual_hub_connection" "spoke-one-uks-vnet-vhub-connection" {
  name                      = "spoke-one-uks-vnet-vhub-connection"
  virtual_hub_id            = azurerm_virtual_hub.vhub-uks.id
  remote_virtual_network_id = azurerm_virtual_network.spoke-one-uks-vnet.id
}

module "spoke-one-vm" {
  source = "../../modules/virtual-machine-linux"

  name            = "spoke-one-uks-vm"
  resource_group  = azurerm_resource_group.spoke-one-uks-rg
  virtual_network = azurerm_virtual_network.spoke-one-uks-vnet

  admin_username = var.vm_admin_username
  admin_password = var.vm_admin_password

  subnet_config = {
    address_prefixes = [local.address_space.spoke_one_uks.vm_subnet]
  }

  tags = local.common_tags
}