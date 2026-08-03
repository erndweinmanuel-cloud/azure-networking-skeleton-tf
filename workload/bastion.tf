resource "azurerm_public_ip" "pip_bastion" {
  name                = "pip-bastion"
  location            = data.azurerm_resource_group.workload.location
  resource_group_name = data.azurerm_resource_group.workload.name

  allocation_method = "Static"
  sku               = "Standard"

  tags = local.common_tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = "bas-main"
  location            = data.azurerm_resource_group.workload.location
  resource_group_name = data.azurerm_resource_group.workload.name

  sku               = "Standard"
  scale_units       = 2
  tunneling_enabled = true

  ip_configuration {
    name                 = "bas-ipcfg"
    subnet_id            = azurerm_subnet.this["hub_bastion"].id
    public_ip_address_id = azurerm_public_ip.pip_bastion.id
  }

  tags = local.common_tags
}
