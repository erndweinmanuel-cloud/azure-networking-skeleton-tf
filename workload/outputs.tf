output "private_ips" {
  description = "Private IP addresses of the workload virtual machines."

  value = {
    for key, nic in azurerm_network_interface.workload :
    key => nic.private_ip_address
  }
}

output "bastion_public_ip" {
  description = "Public IP address assigned to Azure Bastion."
  value       = azurerm_public_ip.pip_bastion.ip_address
}

output "resource_group_name" {
  description = "Name of the workload resource group."
  value       = data.azurerm_resource_group.workload.name
}

output "virtual_network_ids" {
  description = "Resource IDs of the hub and spoke virtual networks."

  value = {
    for key, vnet in azurerm_virtual_network.this :
    key => vnet.id
  }
}

output "subnet_ids" {
  description = "Resource IDs of all hub and spoke subnets."

  value = {
    for key, subnet in azurerm_subnet.this :
    key => subnet.id
  }
}

output "peering_ids" {
  description = "Resource IDs of all virtual network peerings."

  value = {
    for key, peering in azurerm_virtual_network_peering.this :
    key => peering.id
  }
}
output "nva_private_ip" {
  description = "Static private IP address of the network virtual appliance."
  value       = azurerm_network_interface.nic_nva.private_ip_address
}

output "route_table_ids" {
  description = "Resource IDs of the spoke route tables."

  value = {
    for key, route_table in azurerm_route_table.spoke :
    key => route_table.id
  }
}
