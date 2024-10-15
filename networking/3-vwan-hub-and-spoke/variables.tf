variable "vm_admin_username" {
  type        = string
  description = "Admin user account name"
}

variable "vm_admin_password" {
  type        = string
  description = "Admin user account password"
  sensitive   = true
}