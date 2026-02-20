variable "location" {
  type    = string
  default = "westeurope"
}

variable "resource_group_name" {
  type = string
}

variable "name_prefix" {
  type    = string
  default = "tazb"
}

variable "vm_name" {
  type    = string
  default = "ryanvm01"
}

variable "vm_size" {
  type    = string
  default = "Standard_B2s_v2"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

# Set to your current public IP /32 (example: "155.190.32.22/32")
variable "ssh_allowed_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

# RSA public key path (Azure accepted RSA when ed25519 failed)
variable "ssh_public_key_path" {
  type    = string
  default = "~/.ssh/id_rsa_azure.pub"
}

# Storage account name must be globally unique and lowercase
variable "storage_name_prefix" {
  type    = string
  default = "ryantazb"
}
