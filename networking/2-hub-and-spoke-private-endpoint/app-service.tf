
# The app-subnet is for outbound traffic from the web app e.g. storage account, database etc.
resource "azurerm_subnet" "app-subnet" {
  name                 = "spoke-one-uks-app-subnet"
  resource_group_name  = azurerm_resource_group.spoke-one-uks-rg.name
  virtual_network_name = azurerm_virtual_network.spoke-one-uks-vnet.name
  address_prefixes     = [local.address_space.spoke_one_uks.app_service_subnet]

  delegation {
    name = "delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
      ]
    }
  }
}

# All the traffic from the app subnet should go to the firewall if it can't be routed within the vnet
# This uses the shared routing table in the hub
resource "azurerm_subnet_route_table_association" "app-subnet-rt" {
  subnet_id      = azurerm_subnet.app-subnet.id
  route_table_id = azurerm_route_table.hub-uks-firewall-rt.id
}

# The pe-subnet is for inbound traffic to the web app
resource "azurerm_subnet" "pe-subnet" {
  name                 = "spoke-one-uks-pe-subnet"
  resource_group_name  = azurerm_resource_group.spoke-one-uks-rg.name
  virtual_network_name = azurerm_virtual_network.spoke-one-uks-vnet.name
  address_prefixes     = [local.address_space.spoke_one_uks.pe_subnet]
  private_link_service_network_policies_enabled = true
}

# The app service plan to host the web app
resource "azurerm_service_plan" "application1-uks-asp" {
  name                = "application1-uks-asp"
  resource_group_name = azurerm_resource_group.spoke-one-uks-rg.name
  location            = azurerm_resource_group.spoke-one-uks-rg.location
  os_type             = "Linux"
  sku_name            = "P0v3"

  tags = local.common_tags
}

# The web application this connects to the app-subnet for outbound connectivity
resource "azurerm_linux_web_app" "application1-uks-web" {
  name                  = "application1-uks-web"
  resource_group_name   = azurerm_resource_group.spoke-one-uks-rg.name
  location              = azurerm_resource_group.spoke-one-uks-rg.location
  service_plan_id       = azurerm_service_plan.application1-uks-asp.id
  virtual_network_subnet_id = azurerm_subnet.app-subnet.id
  https_only            = true
  public_network_access_enabled = false
  
  site_config {  
    minimum_tls_version = 1.2
    ftps_state = "Disabled"
  }

  tags = local.common_tags
}

# Private endpoint for the web application connects to the pe-subnet for inbound connectivity
resource "azurerm_private_endpoint" "application1-uks-web-pe" {
  name                = "application1-uks-web-pe"
  location            = azurerm_resource_group.spoke-one-uks-rg.location
  resource_group_name = azurerm_resource_group.spoke-one-uks-rg.name
  subnet_id           = azurerm_subnet.pe-subnet.id

  # this allows the pe resource to automatically get a DNS record provisioned.
  private_dns_zone_group {
    name                 = "dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.hub-uks-web-pdnszone.id]
  }

  # what is the NIC for the PE actually connected to
  private_service_connection {    
    name                            = "spoke-one-web-psc"
    private_connection_resource_id  = azurerm_linux_web_app.application1-uks-web.id
    is_manual_connection            = false
    subresource_names               = ["sites"]
  }
}