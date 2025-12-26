locals {
  backend_address_pool_name      = "beap"
  frontend_port_name             = "feport"
  http_setting_name              = "be-htst"
  listener_name                  = "httplstn"
  request_routing_rule_name      = "rqrt"
  redirect_configuration_name    = "rdrcfg"
}

resource "azurerm_application_gateway" "Application_Gateway" {
    for_each = var.agw
  name                = each.key
  resource_group_name = var.rg[each.value.rgkey].name
  location            = var.rg[each.value.rgkey].local

  sku {
    name     = each.value.sku_name
    tier     = each.value.sku_tier
    capacity = each.value.sku_capacity
  }

  gateway_ip_configuration {
    name      = "${each.key}-gateway_ip"
    subnet_id = var.sbnet[each.value.netkey].id
  }

  frontend_ip_configuration {
    name                 = "${each.key}-frontend_ip"
    public_ip_address_id = var.pip[each.value.ipkey].id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    path                  = "/path1/"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = "${each.key}-frontend_ip"
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    priority                   = 9
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
