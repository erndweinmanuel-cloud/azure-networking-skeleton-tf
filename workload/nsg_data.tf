resource "azurerm_network_security_group" "nsg_db" {
  name                = "nsg-data"
  location            = data.azurerm_resource_group.workload.location
  resource_group_name = data.azurerm_resource_group.workload.name

  tags = local.common_tags
}

# Allow application traffic from the app spoke to the database workload.
resource "azurerm_network_security_rule" "allow_8080_web_to_db" {
  name      = "allow-app-to-data-8080"
  priority  = 110
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "8080"

  source_application_security_group_ids = [
    azurerm_application_security_group.this["app"].id
  ]

  destination_application_security_group_ids = [
    azurerm_application_security_group.this["data"].id
  ]

  resource_group_name         = data.azurerm_resource_group.workload.name
  network_security_group_name = azurerm_network_security_group.nsg_db.name
}

# Allow SSH management access only from Azure Bastion in the hub.
resource "azurerm_network_security_rule" "allow_ssh_to_db_from_bastion" {
  name      = "allow-ssh-from-bastion"
  priority  = 100
  direction = "Inbound"
  access    = "Allow"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "22"

  source_address_prefix = azurerm_subnet.this["hub_bastion"].address_prefixes[0]

  destination_application_security_group_ids = [
    azurerm_application_security_group.this["data"].id
  ]

  resource_group_name         = data.azurerm_resource_group.workload.name
  network_security_group_name = azurerm_network_security_group.nsg_db.name
}

# Explicitly deny SSH from every source except the higher-priority Bastion rule.
resource "azurerm_network_security_rule" "deny_ssh_inbound_db" {
  name      = "deny-ssh-from-non-bastion"
  priority  = 200
  direction = "Inbound"
  access    = "Deny"
  protocol  = "Tcp"

  source_port_range      = "*"
  destination_port_range = "22"

  source_address_prefix      = "*"
  destination_address_prefix = "*"

  resource_group_name         = data.azurerm_resource_group.workload.name
  network_security_group_name = azurerm_network_security_group.nsg_db.name
}

resource "azurerm_subnet_network_security_group_association" "db_assoc" {
  subnet_id                 = azurerm_subnet.this["data_workload"].id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}
