terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.43.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.33.0"
    }

  }
}

provider "azurerm" {
  features {}
}
provider "azuread" {}

data "azurerm_subscription" "current" {}
data "azuread_client_config" "current" {}

locals {}

resource "random_string" "sp_secret" {
  length  = 24
  special = false
}

resource "azuread_application" "setup" {
  display_name = "xyz-infra-spn"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_application_password" "setup" {
  display_name          = "tfgenerated"
  application_object_id = azuread_application.setup.object_id
}

resource "azuread_service_principal" "setup" {
  application_id               = azuread_application.setup.application_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_directory_role" "setup" {
  display_name = "Groups Administrator"
}

resource "azuread_directory_role_assignment" "setup" {
  role_id             = azuread_directory_role.setup.template_id
  principal_object_id = azuread_service_principal.setup.object_id
}

resource "azurerm_role_assignment" "contributor" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.setup.id
}

resource "azurerm_role_assignment" "user_access_administrator" {
  scope                = "/subscriptions/${data.azurerm_subscription.current.subscription_id}"
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_service_principal.setup.id
}

resource "azurerm_resource_provider_registration" "kubernetes" {
  name = "Microsoft.Kubernetes"
}

# Auto registered by azurerm
#resource "azurerm_resource_provider_registration" "containerservice" {
#  name = "Microsoft.ContainerService"
#}

resource "azurerm_resource_provider_registration" "kubernetesconfiguration" {
  name = "Microsoft.KubernetesConfiguration"
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

output "spn" {
  value = azuread_service_principal.setup
}

output "client_id" {
  value = azuread_service_principal.setup.application_id
}

output "client_secret" {
  value     = azuread_application_password.setup.value
  sensitive = true
}

output "tenant_id" {
  value = azuread_service_principal.setup.application_tenant_id
}
