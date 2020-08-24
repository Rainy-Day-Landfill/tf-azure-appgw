data "azurerm_virtual_network" "appgw-frontend-vnet" {
  name                = local.frontend_vnet
  resource_group_name = "networking-${var.region}"
}

# requires user input
data "azurerm_subnet" "appgw-frontend-subnet" {
  name                 = "appgw-ingress"
  resource_group_name  = data.azurerm_virtual_network.appgw-frontend-vnet.resource_group_name
  virtual_network_name = data.azurerm_virtual_network.appgw-frontend-vnet.name
}

# requires user input
data "azurerm_subnet" "appgw-backend-subnet" {
  name                 = var.backend_subnet_name
  resource_group_name  = var.backend_subnet_parent_rg
  virtual_network_name = var.backend_subnet_parent_vnet
}

