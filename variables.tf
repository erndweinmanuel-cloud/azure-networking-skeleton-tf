variable "rg_name" {
  type        = string
  description = "Name of the Azure resource group."
  default     = "rg-networking-tf"
}

variable "location" {
  type        = string
  description = "Azure region used for the deployment."
  default     = "westeurope"
}

variable "admin_username" {
  type        = string
  description = "Administrator username for the Linux virtual machines."
  default     = "azureuser"
}

variable "ssh_public_key" {
  type        = string
  description = "OpenSSH public key used for Linux virtual machine access."
  sensitive   = true

  validation {
    condition = can(
      regex(
        "^ssh-(ed25519|rsa|ecdsa-[^ ]+) ",
        trimspace(var.ssh_public_key)
      )
    )

    error_message = "ssh_public_key must contain a valid OpenSSH public key."
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment used for tagging and naming."
  default     = "lab"
}

variable "project_name" {
  type        = string
  description = "Project name used for tagging and resource identification."
  default     = "azure-networking-skeleton"
}