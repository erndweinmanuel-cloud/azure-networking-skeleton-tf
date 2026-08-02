resource "azurerm_network_security_group" "nsg_web" {
  name                = "nsg-app"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = local.common_tags
}

# Allow SSH management access only from Azure Bastion in the hub.
resource "azurerm_network_security_rule" "allow_ssh_to_web_from_bastion" {
  name      = "allow-ssh-from-bastion"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "22"

  source_address_prefix      = azurerm_subnet.this["hub_bastion"].address_prefixes[0]
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_web.name
}

# Explicitly deny SSH from every source except the higher-priority Bastion rule.
resource "azurerm_network_security_rule" "deny_ssh_inbound_web" {
  name      = "deny-ssh-from-non-bastion"
  priority  = 200
  direction = "Inbound"
  access    = "Deny"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "22"

  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg_web.name
}

resource "azurerm_subnet_network_security_group_association" "web_assoc" {
  subnet_id                 = azurerm_subnet.this["app_workload"].id
  network_security_group_id = azurerm_network_security_group.nsg_web.id
}