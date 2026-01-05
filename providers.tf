terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
}


provider "azurerm" {
  features {}
  subscription_id = "a51a94c7-ee9c-48b6-8880-e0c4c1452650"
}
