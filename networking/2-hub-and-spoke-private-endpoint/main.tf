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
      app_service_subnet = "10.10.11.0/24"
      pe_subnet = "10.10.12.0/24"
    }
    spoke_two_uks = {
      vnet      = "10.20.0.0/16"
      vm_subnet = "10.20.10.0/24"
    }
    spoke_three_uks = {
      vnet      = "10.11.0.0/16"
      vm_subnet = "10.11.10.0/24"
    }
  }

  common_tags = {
    sample = "2-hub-and-spoke-private-endpoint"
  }
}