resource "azurerm_resource_group" "spoke-one-uks-rg" {
  name     = "spoke-one-uks-rg"
  location = "UK South"

  tags = local.common_tags
}

# Create the spoke
resource "azurerm_virtual_network" "spoke-one-uks-vnet" {
  name                = "spoke-one-uks-vnet"
  location            = azurerm_resource_group.spoke-one-uks-rg.location
  resource_group_name = azurerm_resource_group.spoke-one-uks-rg.name
  address_space       = [local.address_space.spoke_one_uks.vnet]

  tags = local.common_tags
}

# Peer the spoke with the hub in both directions
resource "azurerm_virtual_network_peering" "hub-uks-spoke-one-uks" {
  name                      = "hub-uks-spoke-one-uks"
  resource_group_name       = azurerm_resource_group.hub-uks-rg.name
  virtual_network_name      = azurerm_virtual_network.hub-uks-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.spoke-one-uks-vnet.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "spoke-one-uks-hub-uks" {
  name                      = "spoke-one-uks-hub-uks"
  resource_group_name       = azurerm_resource_group.spoke-one-uks-rg.name
  virtual_network_name      = azurerm_virtual_network.spoke-one-uks-vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub-uks-vnet.id
  allow_forwarded_traffic   = true
}

# Deploy a VM to the VM Subnet in the spoke
module "spoke-one-vm" {
  source = "../../modules/virtual-machine-linux"

  name            = "spoke-one-uks-vm"
  resource_group  = azurerm_resource_group.spoke-one-uks-rg
  virtual_network = azurerm_virtual_network.spoke-one-uks-vnet

  admin_username = var.vm_admin_username
  admin_password = var.vm_admin_password

  subnet_config = {
    route_table      = azurerm_route_table.hub-uks-firewall-rt
    address_prefixes = [local.address_space.spoke_one_uks.vm_subnet]
  }

  tags = local.common_tags
}

# Link the Private DNS Zone for Azure Websites from the hub to the spoke
resource "azurerm_private_dns_zone_virtual_network_link" "spoke-one-uks-vnet-web-pl-link" {
  name = "spoke-one-uks-vnet-web-pl-link"
  resource_group_name = azurerm_private_dns_zone.hub-uks-web-pdnszone.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.hub-uks-web-pdnszone.name
  virtual_network_id = azurerm_virtual_network.spoke-one-uks-vnet.id
  registration_enabled = false
}