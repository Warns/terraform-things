resource "azurerm_resource_group" "wagtail" {
  name     = "resource-group-wagtail"
  location = var.location
  tags = {
    env = "dev-wagtail-rg"
  }
}
