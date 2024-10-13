locals {
  hub_uks_fw_name = "hub-uks-fw"
}

resource "azurerm_subnet" "hub-uks-firewall-subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub-uks-rg.name
  virtual_network_name = azurerm_virtual_network.hub-uks-vnet.name
  address_prefixes     = [local.address_space.hub_uks.firewall_subnet]
}

resource "azurerm_public_ip" "hub-uks-firewall-pip" {
  name                = "${local.hub_uks_fw_name}-pip"
  location            = azurerm_resource_group.hub-uks-rg.location
  resource_group_name = azurerm_resource_group.hub-uks-rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall_policy" "hub-uks-firewall-policy" {
  name                     = "${local.hub_uks_fw_name}-policy"
  location            = azurerm_resource_group.hub-uks-rg.location
  resource_group_name = azurerm_resource_group.hub-uks-rg.name
  sku                      = "Standard"
  threat_intelligence_mode = "Alert"
}

resource "azurerm_firewall_policy_rule_collection_group" "hub-uks-firewall-rc" {
  name               = "routing"
  firewall_policy_id = azurerm_firewall_policy.hub-uks-firewall-policy.id
  priority           = 500

  network_rule_collection {
    name     = "allow-spoke-one-spoke-two"
    priority = 400
    action   = "Allow"
    rule {
      name                  = "spoke-one-spoke-two"
      protocols             = ["Any"]
      source_addresses      = [local.address_space.spoke_one_uks.vnet, local.address_space.spoke_two_uks.vnet]
      destination_addresses = [local.address_space.spoke_one_uks.vnet, local.address_space.spoke_two_uks.vnet]
      destination_ports     = ["*"]
    }
  }
}

resource "azurerm_firewall" "hub-uks-firewall" {
  name                = local.hub_uks_fw_name
  location            = azurerm_resource_group.hub-uks-rg.location
  resource_group_name = azurerm_resource_group.hub-uks-rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.hub-uks-firewall-subnet.id
    public_ip_address_id = azurerm_public_ip.hub-uks-firewall-pip.id
  }

  firewall_policy_id = azurerm_firewall_policy.hub-uks-firewall-policy.id
}

resource "azurerm_route_table" "hub-uks-firewall-rt" {
  name                = "${local.hub_uks_fw_name}-rt"
  location            = azurerm_resource_group.hub-uks-rg.location
  resource_group_name = azurerm_resource_group.hub-uks-rg.name

  route {
    name                   = "nva-route"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.hub-uks-firewall.ip_configuration[0].private_ip_address
  }

  tags = local.common_tags
}