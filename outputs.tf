output "rg_name" {
  value = azurerm_resource_group.rg.name
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "frontend_public_ip" {
  value = azurerm_public_ip.pip_front.ip_address
}
