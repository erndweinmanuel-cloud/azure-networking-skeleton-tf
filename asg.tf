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

# Associate NIC -> ASG (web)
resource "azurerm_network_interface_application_security_group_association" "nic_web_asg_web" {
  network_interface_id          = azurerm_network_interface.nic_web.id
  application_security_group_id = azurerm_application_security_group.asg_web.id
}

# Associate NIC -> ASG (db)
resource "azurerm_network_interface_application_security_group_association" "nic_db_asg_db" {
  network_interface_id          = azurerm_network_interface.nic_db.id
  application_security_group_id = azurerm_application_security_group.asg_db.id
}

