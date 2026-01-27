resource "azurerm_network_security_group" "nsg_frontend" {
  name                = "nsg-frontend"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Allow SSH from Azure Bastion subnet only
resource "azurerm_network_security_rule" "allow_ssh_from_bastion" {
  name                        = "allow-ssh-from-bastion"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = azurerm_subnet.bastion.address_prefixes[0]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_frontend.name
}

# Allow RDP from Azure Bastion subnet only (harmless for Linux, but future-proof)
resource "azurerm_network_security_rule" "allow_rdp_from_bastion" {
  name                        = "allow-rdp-from-bastion"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "3389"
  source_address_prefix       = azurerm_subnet.bastion.address_prefixes[0]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_frontend.name
}

# Explicit deny SSH inbound from anywhere else
resource "azurerm_network_security_rule" "deny_ssh_inbound" {
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
  network_security_group_name = azurerm_network_security_group.nsg_frontend.name
}

# Explicit deny RDP inbound from anywhere else
resource "azurerm_network_security_rule" "deny_rdp_inbound" {
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
  network_security_group_name = azurerm_network_security_group.nsg_frontend.name
}

# Attach NSG to frontend NIC
resource "azurerm_network_interface_security_group_association" "frontend_nic_assoc" {
  network_interface_id      = azurerm_network_interface.nic_front.id
  network_security_group_id = azurerm_network_security_group.nsg_frontend.id
}
