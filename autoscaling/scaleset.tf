resource "azurerm_linux_virtual_machine_scale_set" "wagtail" {
  name                = "wagtailtestscaleset-1"
  location            = var.location
  resource_group_name = azurerm_resource_group.wagtail.name

  # automatic rolling upgrade
  automatic_os_upgrade = true
  upgrade_policy_mode  = "Rolling"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }

  # required when using rolling upgrade policy
  health_probe_id = azurerm_lb_probe.wagtail.id

  zones = var.zones

  sku {
    name     = "Standard_A1_v2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_profile_data_disk {
    lun           = 0
    caching       = "ReadWrite"
    create_option = "Empty"
    disk_size_gb  = 10
  }

  os_profile {
    computer_name_prefix = "wagtail"
    admin_username       = "wagtail"
    custom_data          = "#!/bin/bash\n\napt-get update && apt-get install -y nginx && systemctl enable nginx && systemctl start nginx"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      key_data = file("mykey.pub")
      path     = "/home/wagtail/.ssh/authorized_keys"
    }
  }

  network_profile {
    name                      = "networkprofile"
    primary                   = true
    network_security_group_id = azurerm_network_security_group.wagtail-instance.id

    ip_configuration {
      name                                   = "IPConfiguration"
      primary                                = true
      subnet_id                              = azurerm_subnet.wagtail-subnet-1.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.bpepool.id]
      load_balancer_inbound_nat_rules_ids    = [azurerm_lb_nat_pool.lbnatpool.id]
    }
  }
}
