############################################
# Observability: Network Watcher + Flow Logs
# Evidence strategy: platform-generated proofs
#
# NOTE:
# - NSG Flow Logs can no longer be created for new targets (blocked by Azure).
# - We use Subnet (VNet) Flow Logs via target_resource_id instead.
############################################

########################
# Network Watcher (regional) - use existing (Azure-managed)
########################
data "azurerm_network_watcher" "nw" {
  name                = "NetworkWatcher_westeurope"
  resource_group_name = "NetworkWatcherRG"
}

########################
# Log Analytics Workspace (KQL evidence)
########################
resource "azurerm_log_analytics_workspace" "law" {
  name                = "law-networking-evidence"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku               = "PerGB2018"
  retention_in_days = 30
}

########################
# Storage Account (required for Flow Logs)
########################
resource "random_string" "sa_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "azurerm_storage_account" "flowlogs" {
  name                = "saflowlogs${random_string.sa_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  public_network_access_enabled   = true
}

########################
# Subnet Flow Logs v2 -> Storage + Traffic Analytics -> Log Analytics
########################

# Web subnet
resource "azurerm_network_watcher_flow_log" "fl_web" {
  name                 = "flowlog-subnet-web"
  network_watcher_name = data.azurerm_network_watcher.nw.name

  # IMPORTANT: must be the Network Watcher RG, not your project RG
  resource_group_name = data.azurerm_network_watcher.nw.resource_group_name
  location            = data.azurerm_network_watcher.nw.location

  # New model: target resource is subnet (not NSG)
  target_resource_id = azurerm_subnet.web.id
  storage_account_id = azurerm_storage_account.flowlogs.id

  enabled = true
  version = 2

  retention_policy {
    enabled = false
    days    = 0
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.law.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.law.location
    workspace_resource_id = azurerm_log_analytics_workspace.law.id
    interval_in_minutes   = 10
  }
}

# DB subnet
resource "azurerm_network_watcher_flow_log" "fl_db" {
  name                 = "flowlog-subnet-db"
  network_watcher_name = data.azurerm_network_watcher.nw.name

  # IMPORTANT: must be the Network Watcher RG, not your project RG
  resource_group_name = data.azurerm_network_watcher.nw.resource_group_name
  location            = data.azurerm_network_watcher.nw.location

  target_resource_id = azurerm_subnet.db.id
  storage_account_id = azurerm_storage_account.flowlogs.id

  enabled = true
  version = 2

  retention_policy {
    enabled = false
    days    = 0
  }

  traffic_analytics {
    enabled               = true
    workspace_id          = azurerm_log_analytics_workspace.law.workspace_id
    workspace_region      = azurerm_log_analytics_workspace.law.location
    workspace_resource_id = azurerm_log_analytics_workspace.law.id
    interval_in_minutes   = 10
  }
}
