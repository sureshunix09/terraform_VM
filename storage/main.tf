provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "storage" {
    name = "anuresource"
  location = "EAST US"
}

resource "azurerm_storage_account" "account" {
    name = "anustorage"
    resource_group_name = azurerm_resource_group.storage.name
    location = azurerm_resource_group.storage.location
    account_tier = "Standard"
    account_replication_type = "LRS"
  
}

resource "azurerm_storage_container" "container" {
     name = "anucontainer"
     storage_account_name = azurerm_storage_account.account.name
     container_access_type = "private"
}

resource "azurerm_storage_blob" "blob" {
     name = "anublob"
     storage_account_name = azurerm_storage_account.account.name
     storage_container_name = azurerm_storage_container.container.name
     type = "Block"
     size = "5120"
       
}

resource "azurerm_storage_share" "share" {
   name = "anusshare"         
   storage_account_name = azurerm_storage_account.account.name
   quota = 50
}

