locals {
  spoke_route_tables = {
    app = {
      name       = "rt-app-via-nva"
      subnet_key = "app_workload"
    }

    data = {
      name       = "rt-data-via-nva"
      subnet_key = "data_workload"
    }
  }

  spoke_routes = {
    app_to_data = {
      name            = "route-app-to-data-via-nva"
      route_table_key = "app"
      address_prefix  = local.virtual_networks["data"].address_space[0]
    }

    data_to_app = {
      name            = "route-data-to-app-via-nva"
      route_table_key = "data"
      address_prefix  = local.virtual_networks["app"].address_space[0]
    }
  }
}

resource "azurerm_route_table" "spoke" {
  for_each = local.spoke_route_tables

  name                = each.value.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  bgp_route_propagation_enabled = false

  tags = local.common_tags
}

resource "azurerm_route" "spoke" {
  for_each = local.spoke_routes

  name                = each.value.name
  resource_group_name = azurerm_resource_group.rg.name
  route_table_name    = azurerm_route_table.spoke[each.value.route_table_key].name

  address_prefix         = each.value.address_prefix
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_network_interface.nic_nva.private_ip_address

  depends_on = [
    azurerm_virtual_network_peering.this
  ]
}

resource "azurerm_subnet_route_table_association" "spoke" {
  for_each = local.spoke_route_tables

  subnet_id      = azurerm_subnet.this[each.value.subnet_key].id
  route_table_id = azurerm_route_table.spoke[each.key].id
}
