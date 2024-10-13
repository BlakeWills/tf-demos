locals {
  hub_uks_bastion_name = "hub-uks-bastion"
}

resource "azurerm_subnet" "hub-uks-bastion-snet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub-rg-uks.name
  virtual_network_name = azurerm_virtual_network.hub-vnet-uks.name
  address_prefixes     = [local.address_space.hub_uks.bastion_subnet]
}

resource "azurerm_public_ip" "hub-uks-bastion-pip" {
  name                = "${local.hub_uks_bastion_name}-pip"
  location            = azurerm_resource_group.hub-rg-uks.location
  resource_group_name = azurerm_resource_group.hub-rg-uks.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Can't use Developer SKU as that doesn't support vnet peering
resource "azurerm_bastion_host" "hub-uks-bastion" {
  name                = local.hub_uks_bastion_name
  location            = azurerm_resource_group.hub-rg-uks.location
  resource_group_name = azurerm_resource_group.hub-rg-uks.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub-uks-bastion-snet.id
    public_ip_address_id = azurerm_public_ip.hub-uks-bastion-pip.id
  }
}

moved {
  from = azurerm_subnet.bastion-snet
  to   = azurerm_subnet.hub-uks-bastion-snet
}

moved {
  from = azurerm_public_ip.bastion-pip
  to   = azurerm_public_ip.hub-uks-bastion-pip
}

moved {
  from = azurerm_bastion_host.bastion
  to   = azurerm_bastion_host.hub-uks-bastion
}
