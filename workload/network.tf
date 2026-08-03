data "azurerm_resource_group" "workload" {
  name = var.rg_name
}
resource "azurerm_virtual_network" "this" {
  for_each = local.virtual_networks

  name                = each.value.name
  location            = data.azurerm_resource_group.workload.location
  resource_group_name = data.azurerm_resource_group.workload.name
  address_space       = each.value.address_space

  tags = local.common_tags
}

resource "azurerm_subnet" "this" {
  # checkov:skip=CKV2_AZURE_31:NSGs are attached through dedicated azurerm_subnet_network_security_group_association resources.
  for_each = local.subnets

  name                 = each.value.name
  resource_group_name  = data.azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.this[each.value.virtual_network].name
  address_prefixes     = each.value.address_prefixes
}

resource "azurerm_virtual_network_peering" "this" {
  for_each = local.peerings

  name = "peer-${each.value.source_vnet}-to-${each.value.remote_vnet}"

  resource_group_name  = data.azurerm_resource_group.workload.name
  virtual_network_name = azurerm_virtual_network.this[each.value.source_vnet].name

  remote_virtual_network_id = azurerm_virtual_network.this[each.value.remote_vnet].id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = each.value.allow_forwarded_traffic
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
