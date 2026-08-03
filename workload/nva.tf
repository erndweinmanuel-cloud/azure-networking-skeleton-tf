resource "azurerm_network_interface" "nic_nva" {
  name                = "nic-nva"
  location            = data.azurerm_resource_group.workload.location
  resource_group_name = data.azurerm_resource_group.workload.name

  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "ipconfig-nva"
    subnet_id                     = azurerm_subnet.this["hub_nva"].id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.4"
  }

  tags = local.common_tags
}

resource "azurerm_linux_virtual_machine" "vm_nva" {
  # checkov:skip=CKV_AZURE_50:AADSSHLoginForLinux is intentionally required for passwordless Microsoft Entra ID SSH authentication.
  identity {
    type = "SystemAssigned"
  }
  name                = "vm-nva01"
  location            = data.azurerm_resource_group.workload.location
  resource_group_name = data.azurerm_resource_group.workload.name
  size                = "Standard_B1s"

  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic_nva.id]

  admin_ssh_key {
    username   = var.admin_username
    public_key = trimspace(var.ssh_public_key)
  }

  disable_password_authentication = true

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

  custom_data = base64encode(<<-CLOUD_INIT
    #cloud-config

    write_files:
      - path: /etc/sysctl.d/99-nva-forwarding.conf
        owner: root:root
        permissions: "0644"
        content: |
          net.ipv4.ip_forward=1

      - path: /usr/local/sbin/configure-nva-forwarding.sh
        owner: root:root
        permissions: "0755"
        content: |
          #!/usr/bin/env bash
          set -euo pipefail

          iptables -N AZURE_NVA_FORWARD 2>/dev/null || true
          iptables -F AZURE_NVA_FORWARD

          iptables -A AZURE_NVA_FORWARD \
            -m conntrack \
            --ctstate ESTABLISHED,RELATED \
            -j ACCEPT

          iptables -A AZURE_NVA_FORWARD \
            -s 10.10.0.0/16 \
            -d 10.20.0.0/16 \
            -j ACCEPT

          iptables -A AZURE_NVA_FORWARD \
            -s 10.20.0.0/16 \
            -d 10.10.0.0/16 \
            -j ACCEPT

          iptables -A AZURE_NVA_FORWARD -j DROP

          iptables -C FORWARD -j AZURE_NVA_FORWARD 2>/dev/null || \
            iptables -I FORWARD 1 -j AZURE_NVA_FORWARD

      - path: /etc/systemd/system/nva-forwarding.service
        owner: root:root
        permissions: "0644"
        content: |
          [Unit]
          Description=Configure Azure NVA IP forwarding
          After=network-online.target
          Wants=network-online.target

          [Service]
          Type=oneshot
          ExecStart=/usr/local/sbin/configure-nva-forwarding.sh
          RemainAfterExit=yes

          [Install]
          WantedBy=multi-user.target

    runcmd:
      - [sysctl, --system]
      - [systemctl, daemon-reload]
      - [systemctl, enable, --now, nva-forwarding.service]
  CLOUD_INIT
  )

  tags = merge(local.common_tags, {
    role = "network-virtual-appliance"
  })
}
