#provider "azurerm" {
  features {}
#}

#resource "azurerm_resource_group" "main" {
  name = "aks-resource-group"
  location = "EAST US"
#}

#data "azuread_group" "aks-resource-group" {
  name = "aks-resource-group"
#}

#module "aks" {
  source              = "Azure/aks/azurerm"
  resource_group_name              = azurerm_resource_group.main.name
  client_id                        = "43e14a85-d55d-4fd5-83bc-5f06a7f746a0"
  client_secret                    = "RPEUFXMipSzav67yosVxJz~wTxygF5_-6C"
  prefix                           = "prefix"
#}
