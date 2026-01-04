variable "rg_name" {
  type    = string
  default = "rg-networking-tf"
}

variable "location" {
  type    = string
  default = "westeurope"
}

variable "vnet_name" {
  type    = string
  default = "vnet-main"
}

variable "my_public_ip_cidr" {
  type        = string
  description = "Your public IP in CIDR, e.g. 83.135.179.151/32"
}

