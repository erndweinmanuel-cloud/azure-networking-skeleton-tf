data "azurerm_network_watcher" "nw" {
  name                = "NetworkWatcher_westeurope"
  resource_group_name = "NetworkWatcherRG"
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-networking-evidence"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku               = "PerGB2018"
  retention_in_days = 30

  tags = local.common_tags
}

resource "random_string" "sa_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "flowlogs" {
  # checkov:skip=CKV_AZURE_33:Queue Storage is not used; this account stores Network Watcher flow logs only.
  # checkov:skip=CKV_AZURE_59:The public endpoint is required for the current GitHub-hosted runner design.
  # checkov:skip=CKV2_AZURE_1:Microsoft-managed encryption is sufficient for this project; CMK would require additional Key Vault and identity infrastructure.
  # checkov:skip=CKV2_AZURE_41:SAS tokens are not used by the current access model.
  # checkov:skip=CKV2_AZURE_40:Shared Key remains enabled until Network Watcher flow logs are migrated to managed identity authentication.
  # checkov:skip=CKV2_AZURE_33:A private endpoint would require private runner connectivity and private DNS, which are outside the current scope.
  # checkov:skip=CKV_AZURE_206:ZRS is an intentional availability and cost decision for this project.

  name                = "saflowlogs${random_string.sa_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "ZRS"
  account_kind             = "StorageV2"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
  shared_access_key_enabled       = true

  blob_properties {
    delete_retention_policy {
      days = 14
    }

    container_delete_retention_policy {
      days = 14
    }
  }

  tags = local.common_tags
}

resource "azurerm_network_watcher_flow_log" "this" {
  for_each = local.flow_log_targets

  name                 = each.value.name
  network_watcher_name = data.azurerm_network_watcher.nw.name
  resource_group_name  = data.azurerm_network_watcher.nw.resource_group_name
  location             = data.azurerm_network_watcher.nw.location

  target_resource_id = azurerm_subnet.this[each.value.subnet_key].id
  storage_account_id = azurerm_storage_account.flowlogs.id

  enabled = true
  version = 2

  retention_policy {
    enabled = true
    days    = 91
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.law.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.law.location
    workspace_resource_id = azurerm_log_analytics_workspace.law.id
    interval_in_minutes   = 10
  }
}