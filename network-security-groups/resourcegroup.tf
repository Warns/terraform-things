resource "azurerm_resource_group" "wagtail" {
  name     = "network-security-group-wagtail"
  location = var.location
  tags = {
    env = "network-security-group-wagtail"
  }
}
