output "frontend_private_ip" {
  value = azurerm_network_interface.nic_front.private_ip_address
}

output "backend_private_ip" {
  value = azurerm_network_interface.nic_back.private_ip_address
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