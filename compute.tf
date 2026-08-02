resource "azurerm_network_interface" "workload" {
  for_each = local.workload_vms

  name                = each.value.nic_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = each.value.ipconfig
    subnet_id                     = azurerm_subnet.this[each.value.subnet_key].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.common_tags
}

resource "azurerm_linux_virtual_machine" "workload" {
  for_each = local.workload_vms

  name                  = each.value.vm_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = each.value.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.workload[each.key].id]

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = trimspace(var.ssh_public_key)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = local.common_tags
}
