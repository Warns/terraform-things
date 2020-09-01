resource "azurerm_resource_group" "wagtail" {
  name = "network-security-group-wagtail"
  location = " var.location
  tags = {
      evn = "network-security-group-wagtail"
  }
}
