provider "azurerm" {
  features {}
}

#resource group
resource "azurerm_resource_group" "scalesetgrp1" {
  name = "sureshscaleset1"
  location = "EAST US"
}

# Vnet
resource "azurerm_virtual_network" "scale_vnet" {
name = "vnetscale"
resource_group_name =  azurerm_resource_group.scalesetgrp1.name
location = azurerm_resource_group.scalesetgrp1.location
address_space = [ "10.0.0.0/16" ]
  
}

#subnet
resource "azurerm_subnet" "subscale" {
  name = "subscale"
  resource_group_name =  azurerm_resource_group.scalesetgrp1.name
  virtual_network_name = azurerm_virtual_network.scale_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# scaleset
resource "azurerm_virtual_machine_scale_set" "scaleset1" {
  name                = "sureshscaleset1"
  location            = azurerm_resource_group.scalesetgrp1.location
  resource_group_name = azurerm_resource_group.scalesetgrp1.name

  # automatic rolling upgrade
  automatic_os_upgrade = true
  upgrade_policy_mode  = "Rolling"

  rolling_upgrade_policy {
    max_batch_instance_percent              = 20
    max_unhealthy_instance_percent          = 20
    max_unhealthy_upgraded_instance_percent = 5
    pause_time_between_batches              = "PT0S"
  }


  sku {
    name     = "Standard_F2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
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
    computer_name_prefix = "testvm"
    admin_username       = "myadmin"
    admin_password = "Password123!!"
  }

  os_profile_linux_config {
    disable_password_authentication = false

  #  ssh_keys {
  #    path     = "/home/myadmin/.ssh/authorized_keys"
 #     key_data = file("~/.ssh/demo_key.pub")
  #  }
 }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "TestIPConfiguration"
      primary                                = true
      subnet_id                              = azurerm_subnet.subscale.id
    
    }
  }

  tags = {
    environment = "staging"
  }
}

# scale set settings

resource "azurerm_monitor_autoscale_setting" "scalemonitor" {
  name                = "automonitorscale"
  location            = azurerm_resource_group.scalesetgrp1.location
  resource_group_name = azurerm_resource_group.scalesetgrp1.name
  target_resource_id  = azurerm_virtual_machine_scale_set.scaleset1.id

  profile {
    name = "defaultProfile"

    capacity {
      default = 1
      minimum = 1
      maximum = 10
    }

    rule {
      metric_trigger {
        metric_name        = "Percentage CPU"
        metric_resource_id = azurerm_virtual_machine_scale_set.scaleset1.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "GreaterThan"
        threshold          = 75
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
        metric_resource_id = azurerm_virtual_machine_scale_set.scaleset1.id
        time_grain         = "PT1M"
        statistic          = "Average"
        time_window        = "PT5M"
        time_aggregation   = "Average"
        operator           = "LessThan"
        threshold          = 25
      }

      scale_action {
        direction = "Decrease"
        type      = "ChangeCount"
        value     = "1"
        cooldown  = "PT1M"
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = true
      send_to_subscription_co_administrator = true
      custom_emails                         = ["admin@contoso.com"]
    }
  }
}