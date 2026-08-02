moved {
  from = azurerm_network_interface.nic_web
  to   = azurerm_network_interface.workload["app"]
}

moved {
  from = azurerm_network_interface.nic_db
  to   = azurerm_network_interface.workload["data"]
}

moved {
  from = azurerm_linux_virtual_machine.vm_web
  to   = azurerm_linux_virtual_machine.workload["app"]
}

moved {
  from = azurerm_linux_virtual_machine.vm_db
  to   = azurerm_linux_virtual_machine.workload["data"]
}
