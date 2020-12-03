provider "azurerm" {
features {}
}

resource "azurerm_resource_group" "azgrp1" {
  name = "${var.prefix}-resource1"
  location = "EAST US"
}

resource "azurerm_virtual_network" "azvnet2" {
    name = "${var.prefix}-vnet2"
    resource_group_name = "${azurerm_resource_group.azgrp1.name}"
    location = "${var.location}"
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = "${azurerm_resource_group.azgrp1.name}"
  virtual_network_name = "${azurerm_virtual_network.azvnet2.name}"
  address_prefixes     = ["10.0.2.0/24"]
      
}

resource "azurerm_network_interface" "main" {
    count                = "${length(var.name_count)}"
    name                 = "${var.prefix}-nic-${count.index+1}"
    location             = "${var.location}"
    resource_group_name  = "${azurerm_resource_group.azgrp1.name}"

    

    ip_configuration {
       name                          = "testconfiguration1"
       subnet_id                     = azurerm_subnet.internal.id
       private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_virtual_machine" "main" {
    count                  = "${length(var.name_count)}"
    name                   = "vmtest-${count.index+1}"
   location                = "${var.location}"
   resource_group_name     = "${azurerm_resource_group.azgrp1.name}"
   vm_size                 = "Standard_DS1_v2"
   network_interface_ids   = ["${element(azurerm_network_interface.main.*.id, count.index)}"]
   delete_data_disks_on_termination = true


    storage_image_reference {
     publisher = "canonical"
     offer = "UbuntuServer"
     sku = "16.04-LTS"
     version ="latest"
    }


    storage_os_disk {
      name              = "myosdisk-${count.index+1}"
      caching           = "ReadWrite"
      create_option     = "FromImage"
      managed_disk_type = "Standard_LRS"
    }

     os_profile {
      computer_name  = "hostname"
      admin_username = "testadmin"
      admin_password = "Password1234!"

     }
    
    os_profile_linux_config {
    disable_password_authentication = false
    }

    tags =  {
     environment = "stagging"  
    }
 
}  

     
output "virtual_machine_name" {
    value = "${azurerm_virtual_machine.main.*.name}"
}


