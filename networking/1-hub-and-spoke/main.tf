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
  }
}