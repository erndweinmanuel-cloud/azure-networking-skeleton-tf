resource "azurerm_network_security_group" "nsg_frontend" {
  name                = "nsg-frontend"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allow_ssh_from_myip" {
  name                        = "allow-ssh-from-myip"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.my_public_ip_cidr
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_frontend.name
}

resource "azurerm_network_interface_security_group_association" "frontend_nic_assoc" {
  network_interface_id      = azurerm_network_interface.nic_front.id
  network_security_group_id = azurerm_network_security_group.nsg_frontend.id
}
