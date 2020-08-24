# References:
# https://www.terraform.io/docs/providers/azurerm/r/application_gateway.html

locals {
  prefix                          = "${var.appname}-${var.env}-${var.region}"
  frontend_vnet                   = "dmzhub-${var.env}-${var.region}-vnet"
  backend_address_pool_name       = "${local.prefix}-appgw-backend-address-pool"
  frontend_port_name              = "${local.prefix}-appgw-frontend-port"
  frontend_ip_configuration_name  = "${local.prefix}-appgw-frontend-ip-configuration"
  http_setting_name               = "${local.prefix}-appgw-frontend-http-settings"
  listener_name                   = "${local.prefix}-appgw-listener"
  request_routing_rule_name       = "${local.prefix}-appgw-request-routing-rule-ingress"
  redirect_configuration_name     = "${local.prefix}-appgw-redirect-configuration"
}

resource "azurerm_resource_group" "appgw-rg" {
  name     = "${local.prefix}-appgw-rg"
  location = var.region
}

# public frontend ip
resource "azurerm_public_ip" "appgw-frontend-ip" {
  name                = "${local.prefix}-appgw-frontend-ip"
  resource_group_name = azurerm_resource_group.appgw-rg.name
  location            = azurerm_resource_group.appgw-rg.location
  allocation_method   = "Dynamic"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "${local.prefix}-appgw"
  resource_group_name = azurerm_resource_group.appgw-rg.name
  location            = azurerm_resource_group.appgw-rg.location

  sku {
    # The Name of the SKU to use for this Application Gateway.
    # Possible values are:
    # ----------------
    # Standard_Small
    # Standard_Medium
    # Standard_Large
    # Standard_v2
    # WAF_Medium
    # WAF_Large
    # WAF_v2
    name     = "Standard_v2"

    # The Tier of the SKU to use for this Application Gateway.
    # Possible values are:
    # ---------------------
    # Standard
    # Standard_v2
    # WAF
    # WAF_v2
    tier     = "Standard_v2"

    # The Capacity of the SKU to use for this Application Gateway.
    # When using a V1 SKU this value must be between 1 and 32
    # When using a V2 SKU this value must be between 1 and 125
    # Note: This property is optional if 'autoscale_configuration' is set.
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"

    # The ID of the Subnet which the Application Gateway should be connected to.
    subnet_id = data.azurerm_subnet.appgw-frontend-subnet
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw-frontend-ip.name
  }

  # requires user input
  backend_address_pool {
    name = local.backend_address_pool_name
  }

  #
  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    # The Path which should be used as a prefix for all HTTP requests.
    path                  = "/path1/"

    # The port which should be used for this Backend HTTP Settings Collection.
    port                  = 80

    # The Protocol which should be used. Possible values are Http and Https.
    protocol              = "Http"

    # The request timeout in seconds, which must be between 1 and 86400 seconds.
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name

    # The Name of the Frontend IP Configuration used for this HTTP Listener.
    frontend_ip_configuration_name = local.frontend_ip_configuration_name

    # The Name of the Frontend Port use for this HTTP Listener.
    frontend_port_name             = local.frontend_port_name

    # Optional: The Hostname which should be used for this HTTP Listener.
    # host_name = optional
    # The Protocol to use for this HTTP Listener. Possible values are Http and Https.
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name

    #  The Type of Routing that should be used for this Rule.
    # Possible values are Basic and PathBasedRouting.
    rule_type                  = "Basic"

    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
