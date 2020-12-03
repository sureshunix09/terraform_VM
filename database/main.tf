provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "sql12" {
  name = "sureshsql12"
  location = "EAST US"                  
}   

#SQL Sevrer
resource "azurerm_sql_server" "sqlserver" {
  name                         = "mssqlserver1"
  resource_group_name          = azurerm_resource_group.sql12.name
  location                     = azurerm_resource_group.sql12.location
  version                      = "12.0"
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
}

#SQL Database

resource "azurerm_sql_database" "sqldatabase" {
  name                = "mssqldatabase1"                               #choose different name & should be unique
  resource_group_name = azurerm_resource_group.sql12.name
  location            = azurerm_resource_group.sql12.location
  server_name         = azurerm_sql_server.sqlserver.name
}


  #firewall rule
resource "azurerm_sql_firewall_rule" "sqlfirewall" {
  name                = "suriFirewallRule11"
  resource_group_name = azurerm_resource_group.sql12.name
  server_name         = azurerm_sql_server.sqlserver.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}