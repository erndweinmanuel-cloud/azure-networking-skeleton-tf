output "resource_group_name" {
  description = "Resource group containing the Terraform state backend."
  value       = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  description = "Globally unique storage account name used by the Terraform backend."
  value       = azurerm_storage_account.tfstate.name
}

output "storage_account_id" {
  description = "Resource ID of the Terraform state storage account."
  value       = azurerm_storage_account.tfstate.id
}

output "container_name" {
  description = "Blob container used for Terraform state."
  value       = azurerm_storage_container.tfstate.name
}