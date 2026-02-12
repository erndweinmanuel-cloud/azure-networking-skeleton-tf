resource "azurerm_network_security_group" "nsg_backend" {
  name                = "nsg-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Allow app traffic: web -> db (8080)
resource "azurerm_network_security_rule" "allow_8080_web_to_db_asg" {
  name      = "allow-app-web-to-db"
  priority  = 110
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "8080"

  source_application_security_group_ids      = [azurerm_application_security_group.asg_web.id]
  destination_application_security_group_ids = [azurerm_application_security_group.asg_db.id]

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_backend.name
}

# Bastion intern erlauben über SSH (nur zum DB-ASG)
resource "azurerm_network_security_rule" "allow_ssh_to_db_from_bastion" {
  name      = "allow-ssh-to-db-from-bastion"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "22"

  source_address_prefix                      = azurerm_subnet.bastion.address_prefixes[0]
  destination_application_security_group_ids = [azurerm_application_security_group.asg_db.id]

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_backend.name
}

# Explizit blocken: SSH
resource "azurerm_network_security_rule" "deny_ssh_inbound_backend" {
  name                        = "deny-ssh-inbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_backend.name
}

# Explizit blocken: RDP
resource "azurerm_network_security_rule" "deny_rdp_inbound_backend" {
  name                        = "deny-rdp-inbound"
  priority                    = 210
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_backend.name
}

# Attach NSG to backend subnet
resource "azurerm_subnet_network_security_group_association" "backend_assoc" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.nsg_backend.id
}
