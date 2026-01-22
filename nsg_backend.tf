resource "azurerm_network_security_group" "nsg_backend" {
  name                = "nsg-backend"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_security_rule" "allow_8080_web_to_db_asg" {
  name                   = "allow-app-web-to-db"
  priority               = 100
  direction              = "Inbound"
  access                 = "Allow"
  protocol               = "Tcp"
  source_port_range      = "*"
  destination_port_range = "8080"

  # ASG statt Subnet/IP Prefix
  source_application_security_group_ids      = [azurerm_application_security_group.asg_web.id]
  destination_application_security_group_ids = [azurerm_application_security_group.asg_db.id]

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_backend.name
}

# Blockt: alles andere aus dem VNet ins Backend (überschreibt Default "AllowVnetInBound")
resource "azurerm_network_security_rule" "deny_all_vnet_inbound" {
  name                        = "deny-vnet-inbound-all"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_backend.name
}

resource "azurerm_subnet_network_security_group_association" "backend_assoc" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.nsg_backend.id
}
