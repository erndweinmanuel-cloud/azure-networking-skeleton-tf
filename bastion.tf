resource "azurerm_public_ip" "pip_bastion" {
  name                = "pip-bastion"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"

  tags = local.common_tags
}

resource "azurerm_bastion_host" "bastion" {
  name                = "bas-main"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku         = "Standard"
  scale_units = 2

  ip_configuration {
    name                 = "bas-ipcfg"
    subnet_id            = azurerm_subnet.this["hub_bastion"].id
    public_ip_address_id = azurerm_public_ip.pip_bastion.id
  }

  tags = local.common_tags
}