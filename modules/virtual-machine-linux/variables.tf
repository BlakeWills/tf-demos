variable "resource_group" {
  type = object({
    name     = string
    location = string
  })

  description = "Resource group to deploy the virtual machine into"
}

variable "virtual_network" {
  type = object({
    name                = string
    resource_group_name = string
  })

  description = "Virtual network to deploy the virtual machine into"
}

variable "subnet_config" {
  type = object({
    address_prefixes = list(string)

    route_table = optional(object({
      id = string
    }))
  })

  description = "Configuration for the virtual machine subnet"
}

variable "name" {
  type        = string
  description = "Name of the virtual machine"
}

variable "sku" {
  type        = string
  default     = "Standard_A1_v2"
  description = "Virtual machine SKU"
}

variable "admin_username" {
  type        = string
  description = "Admin user account name"
}

variable "admin_password" {
  type        = string
  description = "Admin user account password"
  sensitive   = true
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to deployed virtual machine"
}