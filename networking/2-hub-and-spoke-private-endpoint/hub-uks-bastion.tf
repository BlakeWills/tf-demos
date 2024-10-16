locals {
  hub_uks_bastion_name = "hub-uks-bastion"
}

resource "azurerm_subnet" "hub-uks-bastion-snet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub-uks-rg.name
  virtual_network_name = azurerm_virtual_network.hub-uks-vnet.name
  address_prefixes     = [local.address_space.hub_uks.bastion_subnet]
}

resource "azurerm_public_ip" "hub-uks-bastion-pip" {
  name                = "${local.hub_uks_bastion_name}-pip"
  location            = azurerm_resource_group.hub-uks-rg.location
  resource_group_name = azurerm_resource_group.hub-uks-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Can't use Developer SKU as that doesn't support vnet peering
resource "azurerm_bastion_host" "hub-uks-bastion" {
  name                = local.hub_uks_bastion_name
  location            = azurerm_resource_group.hub-uks-rg.location
  resource_group_name = azurerm_resource_group.hub-uks-rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub-uks-bastion-snet.id
    public_ip_address_id = azurerm_public_ip.hub-uks-bastion-pip.id
  }
}