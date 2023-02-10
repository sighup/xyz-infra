data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

resource "random_id" "id" {
  byte_length = 2
}

locals {
  settings       = yamldecode(file("settings.yaml"))
  generated_name = join("-", ["xyz", random_id.id.dec])
}

resource "azurerm_resource_group" "resource_group" {
  name     = join("-", [local.generated_name, "rg"])
  location = local.settings.location
}