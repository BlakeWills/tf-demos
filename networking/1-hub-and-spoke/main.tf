terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.5"
    }
  }
}

provider "azurerm" {
  features {}
}

locals {
  address_space = {
    hub_uks = {
      vnet            = "10.0.0.0/16"
      bastion_subnet  = "10.0.5.0/27"
      firewall_subnet = "10.0.10.0/24"
    }
    spoke_one_uks = {
      vnet      = "10.10.0.0/16"
      vm_subnet = "10.10.10.0/24"
    }
    spoke_two_uks = {
      vnet      = "10.20.0.0/16"
      vm_subnet = "10.20.10.0/24"
    }
  }

  common_tags = {
    sample = "1-hub-and-spoke"
    environment     = "development"
    cost_code       = "code_value"
    created_by      = "james.bancroft7@nhs.net"
    created_date    = "01/01/2024"
    tech_lead       = "james.bancroft7@nhs.net"
    requested_by    = "james.bancroft7@nhs.net"
    service_product = "development"
    team            = "development"
    service_level   = "bronze"
  }
}