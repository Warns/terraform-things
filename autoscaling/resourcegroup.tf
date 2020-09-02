resource "azurerm_resource_group" "wagtail" {
  name     = "autoscaling-wagtail"
  location = var.location
}
