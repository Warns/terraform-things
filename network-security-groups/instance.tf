# wagtail demo 
resource "azurerm_virtual_machine" "wagtail-instance1" {
  name = ${var.prefix}-vm
  location = var.location
  resource_group_name = [azurerm_resource_group.wagtail-instance-1.id]
  vm_size = "Standard_A1_v2"

# Since this is a demo, delete all data on termination
delete_os_disk_on_termination = true
delete_data_disks_on_termination = true

storage_image_reference {
  publisher = "Canonical"
  offer = "UbuntuServer"
  sku = "18.04-LTS"
  version = "latest"
}

storage_os_disk {
  name = "wagtailosdisk1"
  caching = "ReadWrite"
  create_option = "FromImage"
  managed_disk_type = "Standard_LRS" # Should be SSD on prod.
}

os_profile {
  computer_name = "wagtail-instance"
  admin_username = "wagtail"
}

os_profile_linux_config {
  disable_password_authentication = true
  ssh_keys {
    key_data = file("terraform.pub")
    path = ""
    }
  }
}

resource "azurerm_network_interface" "wagtail-instance-1" {
  name = "${var.prefix}-instance1"
  location = var.location
  resource_group_name = azurerm_resource_group.wagtail.name
  network_security_group_id = azurerm_network_security_group.allow-ssh.id
  
  ip_configuration {
  name = "instance1"
  subnet_id = "azurerm_subnet_wagtail-internal-1.id
  private_ip_address_allocation = "Dynamic"
  public_ip_address_id = azurerm_public_ip.wagtail-instance-1.id
}

resource "azurerm_public_ip "wagtail-instance-1" {
  name = "instance1-public-ip"
  location = var.location
  resource_group_name = azurerm_resource_group.wagtail.name
  allocation_method = "Dynamic"
}

resource "azurerm_application_security_group" "wagtail-instance-group" {
  name = "internet-facing"
  location = var.location
  resource_group_name = azurerm_resource_group.wagtail.name
}

resource "azurerm_network_interface_application_security_group_association" "demo-instance-group" {
  network_interface_id = azurerm_network_interface.wagtail-instance-1.id
  ip_configuration_name = "instance1"
  application_security_group_id = azurerm_application_security_group.wagtail-instance-group.id
}

# wagtail demo instance 2
resource "azurerm_virtual_machine" "demo-instance-2" {
  name = "${var.prefix}-vm-2"
  location = var.location
  resource_group_name = azurerm_resource_group.wagtail.name
  network_interface_ids = [azurerm_network_interface.wagtail-instance-2.id]
  vm_size = "Standard_A1_v2"

# delete all data on termination?
delete_os_disk_on_termination = true
delete_data_disks_on_termination = true

storage_image_reference {
  publisher = "Canonical"
  offer = "UbuntuServer"
  sku = "18.04-LTS"
  version = "latest"
}

storage_os_disk {
  name = "wagtailosdisk2"
  caching = "ReadWrite"
  create_option = "FromImage"
  managed_disk_type = "Standard_LRS" # Should be SSD on prod.
}

os_profile {
  computer_name = "wagtail-instance"
  admin_username = "wagtail"
}

os_profile_linux_config {
  disable_password_authentication = true
  ssh_keys {
    key_data = file("terraform.pub")
    path = ""
    }
  }
}

resource "azurerm_network_interface" "wagtail-instance-2" {
  name = "${var.prefix}-instance2"
  location = var.location
  resource_group_name = azurerm_resource_group.wagtail.name
  network_security_group_id = azurerm_network_security_group.internal-facing.id # This will have an internal facing security group in network.tf
  
  ip_configuration {
  name = "instance2"
  subnet_id = "azurerm_subnet_wagtail-internal-1.id
  private_ip_address_allocation = "Dynamic"
  public_ip_address_id = azurerm_public_ip.wagtail-instance-1.id
  }

resource "azurerm_public_ip "wagtail-instance-2" {
  name = "instance2-public-ip"
  location = var.location
  resource_group_name = azurerm_resource_group.wagtail.name
  allocation_method = "Dynamic"
}

resource "azurerm_application_security_group" "wagtail-instance-group" {
  name = "internet-facing"
  location = var.location
  resource_group_name = azurerm_resource_group.wagtail.name
}

resource "azurerm_network_interface_application_security_group_association" "demo-instance-group" {
  network_interface_id = azurerm_network_interface.wagtail-instance-2.id
  ip_configuration_name = "instance2"
  application_security_group_id = azurerm_application_security_group.wagtail-instance-group.id
}

