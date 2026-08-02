resource "azurerm_application_security_group" "this" {
  for_each = local.application_security_groups

  name                = each.value.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.common_tags
}

resource "azurerm_network_interface_application_security_group_association" "this" {
  for_each = local.workload_vms

  network_interface_id = azurerm_network_interface.workload[each.key].id

  application_security_group_id = (
    azurerm_application_security_group.this[each.key].id
  )
}
