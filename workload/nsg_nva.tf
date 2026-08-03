resource "azurerm_network_security_group" "nsg_nva" {
  name                = "nsg-nva"
  location            = data.azurerm_resource_group.workload.location
  resource_group_name = data.azurerm_resource_group.workload.name

  tags = local.common_tags
}

# Allow SSH management only from Azure Bastion.
resource "azurerm_network_security_rule" "allow_ssh_to_nva_from_bastion" {
  name      = "allow-ssh-from-bastion"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "22"

  source_address_prefix      = azurerm_subnet.this["hub_bastion"].address_prefixes[0]
  destination_address_prefix = "10.0.1.4"

  resource_group_name         = data.azurerm_resource_group.workload.name
  network_security_group_name = azurerm_network_security_group.nsg_nva.name
}

# Allow forwarded application traffic from the app subnet to the data subnet.
resource "azurerm_network_security_rule" "allow_app_to_data_via_nva" {
  name      = "allow-app-to-data-via-nva"
  priority  = 110
  direction = "Inbound"
  access    = "Allow"
  protocol  = "*"

  source_port_range      = "*"
  destination_port_range = "*"

  source_address_prefix      = azurerm_subnet.this["app_workload"].address_prefixes[0]
  destination_address_prefix = azurerm_subnet.this["data_workload"].address_prefixes[0]

  resource_group_name         = data.azurerm_resource_group.workload.name
  network_security_group_name = azurerm_network_security_group.nsg_nva.name
}

# Allow the symmetric return path from the data subnet to the app subnet.
resource "azurerm_network_security_rule" "allow_data_to_app_via_nva" {
  name      = "allow-data-to-app-via-nva"
  priority  = 120
  direction = "Inbound"
  access    = "Allow"
  protocol  = "*"

  source_port_range      = "*"
  destination_port_range = "*"

  source_address_prefix      = azurerm_subnet.this["data_workload"].address_prefixes[0]
  destination_address_prefix = azurerm_subnet.this["app_workload"].address_prefixes[0]

  resource_group_name         = data.azurerm_resource_group.workload.name
  network_security_group_name = azurerm_network_security_group.nsg_nva.name
}

# Explicitly deny SSH from every source except the higher-priority Bastion rule.
resource "azurerm_network_security_rule" "deny_ssh_to_nva_from_non_bastion" {
  name      = "deny-ssh-from-non-bastion"
  priority  = 200
  direction = "Inbound"
  access    = "Deny"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "22"

  source_address_prefix      = "*"
  destination_address_prefix = "10.0.1.4"

  resource_group_name         = data.azurerm_resource_group.workload.name
  network_security_group_name = azurerm_network_security_group.nsg_nva.name
}

resource "azurerm_subnet_network_security_group_association" "nva_assoc" {
  subnet_id                 = azurerm_subnet.this["hub_nva"].id
  network_security_group_id = azurerm_network_security_group.nsg_nva.id
}
