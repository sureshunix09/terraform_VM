resource "azurerm_network_security_group" "security" {

    name = "mysecuritygroup"
    resource_group_name = "${azurerm_resource_group.azgrp1.name}"
    location             = "${var.location}"
}    

resource "azurerm_network_security_rule" "security" {
      
      access = "allow"
      description = "Creating security group"
      destination_address_prefix = "*"
      direction = "Inbound"
      name = "ssh"
      priority = 100
      protocol = "Tcp"
      source_address_prefix = "*"
      source_port_ranges = [ "22" ]
      resource_group_name = "${azurerm_resource_group.azgrp1.name}"
      network_security_group_name = "${azurerm_network_security_group.security.name}"
}  