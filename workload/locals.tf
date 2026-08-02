locals {
  common_tags = {
    environment  = var.environment
    project      = var.project_name
    managed_by   = "terraform"
    architecture = "hub-spoke"
  }

  virtual_networks = {
    hub = {
      name          = "vnet-hub"
      address_space = ["10.0.0.0/16"]
    }

    app = {
      name          = "vnet-spoke-app"
      address_space = ["10.10.0.0/16"]
    }

    data = {
      name          = "vnet-spoke-data"
      address_space = ["10.20.0.0/16"]
    }
  }

  subnets = {
    hub_bastion = {
      name             = "AzureBastionSubnet"
      virtual_network  = "hub"
      address_prefixes = ["10.0.0.0/26"]
    }

    hub_nva = {
      name             = "snet-nva"
      virtual_network  = "hub"
      address_prefixes = ["10.0.1.0/24"]
    }

    app_workload = {
      name             = "snet-app"
      virtual_network  = "app"
      address_prefixes = ["10.10.1.0/24"]
    }

    data_workload = {
      name             = "snet-data"
      virtual_network  = "data"
      address_prefixes = ["10.20.1.0/24"]
    }
  }

  peerings = {
    hub_to_app = {
      source_vnet             = "hub"
      remote_vnet             = "app"
      allow_forwarded_traffic = true
    }

    app_to_hub = {
      source_vnet             = "app"
      remote_vnet             = "hub"
      allow_forwarded_traffic = true
    }

    hub_to_data = {
      source_vnet             = "hub"
      remote_vnet             = "data"
      allow_forwarded_traffic = true
    }

    data_to_hub = {
      source_vnet             = "data"
      remote_vnet             = "hub"
      allow_forwarded_traffic = true
    }
  }

  application_security_groups = {
    app = {
      name = "asg-app"
    }

    data = {
      name = "asg-data"
    }
  }

  workload_vms = {
    app = {
      vm_name    = "vm-web01"
      nic_name   = "nic-web"
      ipconfig   = "ipconfig-web"
      subnet_key = "app_workload"
      vm_size    = "Standard_B2s"
    }

    data = {
      vm_name    = "vm-db01"
      nic_name   = "nic-db"
      ipconfig   = "ipconfig-db"
      subnet_key = "data_workload"
      vm_size    = "Standard_B2s"
    }
  }
  flow_log_targets = {
    app = {
      name       = "flowlog-snet-app"
      subnet_key = "app_workload"
    }

    data = {
      name       = "flowlog-snet-data"
      subnet_key = "data_workload"
    }
  }
}