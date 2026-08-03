resource "random_string" "storage_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_resource_group" "tfstate" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_storage_account" "tfstate" {
  # checkov:skip=CKV2_AZURE_21:Blob read diagnostics require a separate logging destination and are outside the current backend scope.
  # checkov:skip=CKV2_AZURE_1:Microsoft-managed encryption is sufficient for this project; CMK would require additional Key Vault and identity infrastructure.
  # checkov:skip=CKV2_AZURE_33:GitHub-hosted runners require the public storage endpoint because no private runner network is available.
  # checkov:skip=CKV_AZURE_33:Queue Storage is not used; this account stores Terraform state in Blob Storage only.
  # checkov:skip=CKV_AZURE_59:The public endpoint is required for GitHub-hosted runners; anonymous access is disabled and authentication uses Entra ID with RBAC.
  # checkov:skip=CKV_AZURE_206:LRS is retained intentionally for this small Terraform backend; blob versioning and soft delete provide recovery protection.

  name = "${var.storage_account_prefix}${random_string.storage_suffix.result}"

  resource_group_name = azurerm_resource_group.tfstate.name
  location            = azurerm_resource_group.tfstate.location

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = true
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 14
    }

    container_delete_retention_policy {
      days = 14
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "tfstate_blob_contributor" {
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.backend_operator_principal_id
}