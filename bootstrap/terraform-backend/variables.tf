variable "location" {
  type        = string
  description = "Azure region for the Terraform state resources."
  default     = "westeurope"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group containing the Terraform state backend."
  default     = "rg-tfstate-networking"
}

variable "storage_account_prefix" {
  type        = string
  description = "Prefix used for the globally unique Terraform state storage account name."
  default     = "sttfnetworking"

  validation {
    condition = (
      length(var.storage_account_prefix) >= 3 &&
      length(var.storage_account_prefix) <= 18 &&
      can(regex("^[a-z0-9]+$", var.storage_account_prefix))
    )

    error_message = "storage_account_prefix must contain only lowercase letters and numbers and be between 3 and 18 characters long."
  }
}

variable "container_name" {
  type        = string
  description = "Name of the private blob container used for Terraform state."
  default     = "tfstate"
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to the Terraform state resources."

  default = {
    environment = "lab"
    project     = "azure-networking-skeleton"
    managed_by  = "terraform"
    purpose     = "terraform-state"
  }
}