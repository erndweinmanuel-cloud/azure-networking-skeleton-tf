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
variable "backend_operator_principal_id" {
  type        = string
  description = "Microsoft Entra object ID that receives Storage Blob Data Contributor on the Terraform backend storage account."

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.backend_operator_principal_id))
    error_message = "backend_operator_principal_id must be a valid Microsoft Entra object ID (UUID)."
  }
}

variable "workload_resource_group_name" {
  type        = string
  description = "Name of the persistent resource group containing the networking workload."
  default     = "rg-networking-tf"
}

variable "workload_tags" {
  type        = map(string)
  description = "Tags applied to the persistent workload resource group."

  default = {
    architecture = "hub-spoke"
    environment  = "lab"
    managed_by   = "terraform"
    project      = "azure-networking-skeleton"
  }
}

variable "github_service_principal_object_id" {
  type        = string
  description = "Microsoft Entra object ID of the GitHub Actions service principal."

  validation {
    condition     = can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.github_service_principal_object_id))
    error_message = "github_service_principal_object_id must be a valid Microsoft Entra object ID."
  }
}
