terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.42.0"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.3.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.17.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.33.0"
    }

  }

}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {
}

provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.aks.kube_admin_config[0].cluster_ca_certificate)
}
