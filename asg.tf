resource "azurerm_application_security_group" "asg_web" {
  name                = "asg-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_application_security_group" "asg_db" {
  name                = "asg-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# NIC -> ASG Zuordnung (Web VM NIC)
resource "azurerm_network_interface_application_security_group_association" "nic_front_asg_web" {
  network_interface_id          = azurerm_network_interface.nic_front.id
  application_security_group_id = azurerm_application_security_group.asg_web.id
}

# NIC -> ASG Zuordnung (DB VM NIC)
resource "azurerm_network_interface_application_security_group_association" "nic_back_asg_db" {
  network_interface_id          = azurerm_network_interface.nic_back.id
  application_security_group_id = azurerm_application_security_group.asg_db.id
}
