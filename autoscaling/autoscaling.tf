resource "azurerm_monitor_autoscale_setting" "example" {
  name                = "wagtail-autoscaling"
  resource_group_name = azurerm_resource_group.wagtail.name
  location            = var.location
  target_resource_id  = azurerm_virtual_machine_scale_set.wagtail.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 2
      minimum = 2
      maximum = 4
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.wagtail.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 40
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.wagtail.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 10
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  # notification {
  #   email {
  #     send_to_subscription_administrator    = true
  #     send_to_subscription_co_administrator = true
  #     custom_emails                         = ["mert@subjebilisim.com"]
    }
  }
}
