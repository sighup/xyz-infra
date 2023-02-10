resource "azurerm_virtual_network" "network" {
  name                = join("-", [local.generated_name, "network"])
  address_space       = [local.settings.vnet.network]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "nodes" {
  name                 = "nodes"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [local.settings.vnet.subnet.nodes]
}

resource "azurerm_subnet" "pods" {
  name                 = "pods"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.network.name
  address_prefixes     = [local.settings.vnet.subnet.pods]

  delegation {
    name = "aks-delegation"

    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
      ]
    }
  }
}

resource "azurerm_network_security_group" "security_group" {
  name                = join("-", [local.generated_name, "nsg"])
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
}

resource "azurerm_subnet_network_security_group_association" "nodes" {
  subnet_id                 = azurerm_subnet.nodes.id
  network_security_group_id = azurerm_network_security_group.security_group.id
}

resource "azurerm_subnet_network_security_group_association" "pods" {
  subnet_id                 = azurerm_subnet.pods.id
  network_security_group_id = azurerm_network_security_group.security_group.id
}

resource "azurerm_network_security_rule" "security_rule" {
  name                        = "inbound-80"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = azurerm_public_ip.public_ip.ip_address
  resource_group_name         = azurerm_resource_group.resource_group.name
  network_security_group_name = azurerm_network_security_group.security_group.name
}

resource "azurerm_public_ip" "public_ip" {
  name                = join("-", [local.generated_name, "pip"])
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  allocation_method = "Static"
}