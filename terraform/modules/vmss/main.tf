#checkov:skip=CKV_AZURE_49:POC - SSH key auth to be implemented before prod
#checkov:skip=CKV_AZURE_178:POC - SSH key auth to be implemented before prod
#checkov:skip=CKV_AZURE_97:POC - Encryption at host to be enabled before prod
#checkov:skip=CKV_AZURE_149:POC - Password auth used for POC only
resource "azurerm_linux_virtual_machine_scale_set" "this" {
  name                = "${var.environment}-vmss"
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.vm_sku
  instances           = var.instance_count
  admin_username      = var.admin_username
  admin_password      = var.admin_password

  disable_password_authentication = false

  custom_data = base64encode(templatefile("${path.module}/cloud-init.tpl", {
    acr_login_server = var.acr_login_server
    acr_username     = var.acr_username
    acr_password     = var.acr_password
    image_tag        = var.image_tag
    environment      = var.environment
  }))

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  network_interface {
    name    = "${var.environment}-vmss-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = [var.backend_pool_id]
    }
  }

  tags = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

resource "azurerm_monitor_autoscale_setting" "this" {
  name                = "${var.environment}-autoscale"
  resource_group_name = var.resource_group_name
  location            = var.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.this.id

  profile {
    name = "default"

    capacity {
      default = var.instance_count
      minimum = var.min_instance_count
      maximum = var.max_instance_count
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.this.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = var.scale_out_cpu_threshold
      }

      scale_action {
        direction = "Increase"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_linux_virtual_machine_scale_set.this.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = var.scale_in_cpu_threshold
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT5M"
      }
    }
  }
}
