resource "azurerm_application_security_group" "this" {
  for_each = local.application_security_groups

  name                = each.value.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.common_tags
}

resource "azurerm_network_interface_application_security_group_association" "this" {
  for_each = {
    app = {
      network_interface_id = azurerm_network_interface.nic_web.id
      asg_key              = "app"
    }

    data = {
      network_interface_id = azurerm_network_interface.nic_db.id
      asg_key              = "data"
    }
  }

  network_interface_id = each.value.network_interface_id

  application_security_group_id = (
    azurerm_application_security_group.this[each.value.asg_key].id
  )
}