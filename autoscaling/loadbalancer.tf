resource "azurerm_lb" "wagtail" {
  name                = "wagtail-loadbalancer"
  sku                 = length(var.zones) == 0 ? "Basic" : "Standard" # Basic is free, but doesn't support Availability Zones
  location            = var.location
  resource_group_name = azurerm_resource_group.wagtail.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.wagtail.id
  }
}

resource "azurerm_public_ip" "wagtail" {
  name                = "wagtail-public-ip"
  location            = var.location
  resource_group_name = azurerm_resource_group.wagtail.name
  allocation_method   = "Static"
  domain_name_label   = azurerm_resource_group.wagtail.name
  sku                 = length(var.zones) == 0 ? "Basic" : "Standard"
}


resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = azurerm_resource_group.wagtail.name
  loadbalancer_id     = azurerm_lb.wagtail.id
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_nat_pool" "lbnatpool" {
  resource_group_name            = azurerm_resource_group.wagtail.name
  name                           = "ssh"
  loadbalancer_id                = azurerm_lb.wagtail.id
  protocol                       = "Tcp"
  frontend_port_start            = 50000
  frontend_port_end              = 50119
  backend_port                   = 22
  frontend_ip_configuration_name = "PublicIPAddress"
}

resource "azurerm_lb_probe" "wagtail" {
  resource_group_name = azurerm_resource_group.wagtail.name
  loadbalancer_id     = azurerm_lb.wagtail.id
  name                = "http-probe"
  protocol            = "Http"
  request_path        = "/"
  port                = 80
}

resource "azurerm_lb_rule" "wagtail" {
  resource_group_name            = azurerm_resource_group.wagtail.name
  loadbalancer_id                = azurerm_lb.wagtail.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = azurerm_lb_probe.wagtail.id
  backend_address_pool_id        = azurerm_lb_backend_address_pool.bpepool.id
}

