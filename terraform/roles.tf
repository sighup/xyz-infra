# Control Plane MI for networking
resource "azurerm_user_assigned_identity" "aks" {
  name                = join("-", [local.generated_name, "cluster-mi"])
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
}

# MI for ACR
resource "azurerm_user_assigned_identity" "kubelet" {
  name                = join("-", [local.generated_name, "kubelet-mi"])
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
}

resource "azurerm_role_assignment" "aks_role_assignemnt_nework" {
  scope                            = azurerm_virtual_network.network.id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_user_assigned_identity.aks.principal_id
  skip_service_principal_aad_check = true
}

# MI for pip in RG
resource "azurerm_role_assignment" "aks_role_assignemnt_resource_group" {
  scope                            = azurerm_resource_group.resource_group.id
  role_definition_name             = "Network Contributor"
  principal_id                     = azurerm_user_assigned_identity.aks.principal_id
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "aks_role_assignemnt_msi" {
  scope                            = azurerm_user_assigned_identity.kubelet.id
  role_definition_name             = "Managed Identity Operator"
  principal_id                     = azurerm_user_assigned_identity.aks.principal_id
  skip_service_principal_aad_check = true
}

resource "azuread_group" "cluster-admins" {
  display_name     = "cluster-admins"
  owners           = [data.azurerm_client_config.current.object_id]
  security_enabled = true
}
