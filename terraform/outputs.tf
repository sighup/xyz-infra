output "cluster_resource_group" {
  value     = azurerm_kubernetes_cluster.aks.resource_group_name
  sensitive = false
}

output "cluster_name" {
  value     = azurerm_kubernetes_cluster.aks.name
  sensitive = false
}

output "public_ip" {
  value     = azurerm_public_ip.public_ip.ip_address
  sensitive = false
}
