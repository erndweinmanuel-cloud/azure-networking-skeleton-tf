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
      role             = "bastion"
    }

    hub_nva = {
      name             = "snet-nva"
      virtual_network  = "hub"
      address_prefixes = ["10.0.1.0/24"]
      role             = "nva"
    }

    app_workload = {
      name             = "snet-app"
      virtual_network  = "app"
      address_prefixes = ["10.10.1.0/24"]
      role             = "app"
    }

    data_workload = {
      name             = "snet-data"
      virtual_network  = "data"
      address_prefixes = ["10.20.1.0/24"]
      role             = "data"
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
}