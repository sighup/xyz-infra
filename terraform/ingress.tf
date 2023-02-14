data "azurerm_kubernetes_cluster" "aks" {
  name                = azurerm_kubernetes_cluster.aks.name
  resource_group_name = azurerm_kubernetes_cluster.aks.resource_group_name
}

resource "kubernetes_config_map" "nginx_ingress_values" {
  depends_on = [
    azapi_resource.flux_config,
  ]
  metadata {
    name      = "nginx-values"
    namespace = "flux-system"

  }

  data = {
    "values.yaml" = <<-YAML
    controller:
      service:
        loadBalancerIP: ${azurerm_public_ip.public_ip.ip_address}
        annotations:
          service.beta.kubernetes.io/azure-load-balancer-resource-group: ${azurerm_resource_group.resource_group.name}
    YAML
  }
}