provider "azurerm" {
  subscription_id = "a51a94c7-ee9c-48b6-8880-e0c4c1452650"

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
