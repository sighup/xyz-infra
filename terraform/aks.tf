resource "random_integer" "services_cidr" {
  min = 64
  max = 127
}

resource "azurerm_kubernetes_cluster" "aks" {
  depends_on = [
    azurerm_public_ip.public_ip
  ]
  name                      = join("-", [local.generated_name, "aks"])
  resource_group_name       = azurerm_resource_group.resource_group.name
  location                  = azurerm_resource_group.resource_group.location
  node_resource_group       = join("", [local.generated_name, "aks-nodes-rg"])
  dns_prefix                = local.generated_name
  sku_tier                  = "Free"
  automatic_channel_upgrade = "patch"
  oidc_issuer_enabled       = true
  local_account_disabled    = false

  azure_active_directory_role_based_access_control {
    managed                = true
    azure_rbac_enabled     = true
    tenant_id              = data.azurerm_client_config.current.tenant_id
    admin_group_object_ids = [azuread_group.cluster-admins.id]
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks.id]
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.kubelet.client_id
    object_id                 = azurerm_user_assigned_identity.kubelet.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.kubelet.id
  }

  default_node_pool {
    name                = "default"
    node_count          = 1
    vm_size             = "Standard_B2s"
    os_disk_size_gb     = 30
    vnet_subnet_id      = azurerm_subnet.nodes.id
    pod_subnet_id       = azurerm_subnet.pods.id
    os_sku              = "CBLMariner"
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 1
    max_pods            = 30
  }

  network_profile {
    dns_service_ip     = "100.${random_integer.services_cidr.id}.0.10"
    service_cidr       = "100.${random_integer.services_cidr.id}.0.0/16"
    docker_bridge_cidr = "172.17.0.1/16"
    network_plugin     = "azure"
    load_balancer_sku  = "basic"
  }
}
