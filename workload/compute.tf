resource "azurerm_network_interface" "workload" {
  for_each = local.workload_vms

  name                = each.value.nic_name
  location            = data.azurerm_resource_group.workload.location
  resource_group_name = data.azurerm_resource_group.workload.name

  ip_configuration {
    name                          = each.value.ipconfig
    subnet_id                     = azurerm_subnet.this[each.value.subnet_key].id
    private_ip_address_allocation = "Dynamic"
  }

  tags = local.common_tags
}

resource "azurerm_linux_virtual_machine" "workload" {
  # checkov:skip=CKV_AZURE_50:AADSSHLoginForLinux is intentionally required for passwordless Microsoft Entra ID SSH authentication.
  for_each = local.workload_vms

  name                  = each.value.vm_name
  location              = data.azurerm_resource_group.workload.location
  resource_group_name   = data.azurerm_resource_group.workload.name
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
