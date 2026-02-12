output "web_private_ip" {
  value = azurerm_network_interface.nic_web.private_ip_address
}

output "db_private_ip" {
  value = azurerm_network_interface.nic_db.private_ip_address
}

output "bastion_public_ip" {
  value = azurerm_public_ip.pip_bastion.ip_address
}

output "rg_name" {
  value = azurerm_resource_group.rg.name
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

