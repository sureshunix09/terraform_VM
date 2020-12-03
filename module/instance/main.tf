module "virtual_machine2" {
    source = "../../virtual_machine2"
    
}

module "virtual_setup" {
    source = "../../resource_group"
    prefix = "secondmachine"
    
}