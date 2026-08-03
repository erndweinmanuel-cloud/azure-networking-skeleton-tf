data "azurerm_client_config" "current" {}

locals {
  entra_login_vms = merge(
    {
      for key, vm in azurerm_linux_virtual_machine.workload :
      key => vm.id
    },
    {
      nva = azurerm_linux_virtual_machine.vm_nva.id
    }
  )
}

resource "azurerm_virtual_machine_extension" "entra_ssh_login" {
  # checkov:skip=CKV_AZURE_50:AADSSHLoginForLinux is intentionally required for passwordless Microsoft Entra ID SSH authentication.
  for_each = local.entra_login_vms

  name                       = "AADSSHLoginForLinux"
  virtual_machine_id         = each.value
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADSSHLoginForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_role_assignment" "vm_administrator_login" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = var.vm_admin_principal_id
}
