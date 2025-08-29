resource "azurerm_resouce_group" "rg" {
    name = "Three-tier-app"
    location = var.available_locations[0]
  
}

resource "azurerm_virtual_network" "Vnet"{
    name = "demo-app-vpc"
    resource_group_name = azurerm_resouce_group.rg.name
    location = azurerm_resource_group.rg.location
    address_space = [ "10.0.0.0/16" ]
}

module "subnets" {
    source = "./modules/subnet"

depends_on = [
    azurerm_virtual_network.Vnet
  ]
  
}

resource "azurerm_private_dns_zone" "dns-zone" {
  name                = "myapp.mysql.database.azure.com"
  resource_group_name = azurerm_resource_group.example.name
}
 
 resource "azurerm_private_dns_zone_virtual_network_link" "dns-link" {
   name = "AppVnetZone"
   resource_group_name = azurerm_resouce_group.rg.name
   virtual_network_id = azurerm_virtual_network.Vnet.id
   private_dns_zone_name = azurerm_private_dns_zone.dns-zone.name

 }

 resource "azurerm_mysql_flexible_server" "Mysqlser" {
    name = "Mysql-server"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    administrator_login    = "admin"
    administrator_password = "H@Sh1CoR3!"
    backup_retention_days  = 7
    delegated_subnet_id = azurerm_subnet.subnet.id
    private_dns_zone_id = azurerm_private_dns_zone.dns-zone.id
    sku_name = "Standard"
           
 }

resource "azurerm_mysql_flexible_database" "my-db" {
 name = "myapp_db"
 resource_group_name = azurerem_resource_group.rg.name
 server_name = azurerm_mysql_flexible_server.Mysqlser.name
 charset = "utf8"
 collation = "utf8_unicode_ci"
}

resource "azurerm_mysql_flexible_server_firewall_rule" "internal" {
    name = "internal-aceess"
    resource_group_name = azurerm_resource_group_rg.name
    server_name = azurerm_mysql_flexible_server.Mysqlser.name
    start_ip_address = "10.0.1.0"
    end_ip_address = "10.0.1.255"
  
}



resource "azurerm_storage_account" "Storage" {
 name = "storageAccount56"
resource_group_name = azurerm_resource_group.rg.name
location = azurerm_resource_group.rg.name
account_replication_type = "LRS"
account_tier = "Standard"
blob_properties {
  versioning_enabled = true
}

}

resource "azurerm_storage_container" "blob" {
  
  name = "storageacontainer56"
  storage_account_id = azurerm_storage_account.Storage.id
  container_access_type = "Private"
}

resource "azurerm_eventgrid_system_topic" "topic" {
  name                = "demo-app-sns-topic"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  source_resource_id  = azurerm_storage_account.Storage.id
  topic_type          = "Microsoft.Storage.StorageAccounts"
}

resource "azurerm_logic_app_workflow" "email_workflow" {
    name = "send-email-on-upload"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
 
}

resource "azurerm_eventgrid_event_subscription" "notify_uploads" {
name = "notify-on-uploads"  
scope = azurerm_eventgrid_system_topic.topic.id
included_event_types = ["Microsoft.Storage.BlobCreated"]
azure_function_endpoint {
    function_id = "${azurerm_linux_function_app.fn.id}/functions/onBlobCreated"
    max_events_per_batch = 1
    preferred_batch_size_in_kilobytes = 64 
}
}

# Cosmos DB (DynamoDB -> Cosmos Table API)

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}
 resource "azurerm_cosmosdb_account" "cosmos" {
name = "cosmos-db-${random_integer.ri.result}"
resource_group_name = azurerm_resource_group.rg.name
location = azurerm_resource_group.rg.location
kind = "GlobalDocumentDB"
offer_type = "Standard"
consistency_policy {
  consistency_level = "Session"
}
capabilities {
  name = "EnableTable"
}
# Table API
 geo_location {
  location = azurerm_resource_group.rg.name
  failover_priority = 0
}  
 }

 resource "azurerm_cosmosdb_table" "filemeta" {
   
name = "file_metadata"
resource_group_name = azurerm_resource_group.rg.name
account_name = azurerm_cosmosdb_account.cosmos.name
throughput = 400
 }

 #Function App (Lambda -> Azure Function)--
 #Function runtime storage
 resource "azurerm_service_plan" "plan" {
    name = "func-plan"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    os_type = "Linux"
    sku_name = "Y1"
   
 }

 resource "azurerm_linux_finction_app" "funapp" {
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    service_plan_id =azurerm_service_plan.plan.id
    storage_account_name = azurerm_storage_account.Storage.name
    storage_account_access_key = azurerm_storage_account.Storage.primary_access_key
    functions_extension_version = "~4"
    
    site_config{
        application_stack{
            python_version = "3.11"
        }
        app_scale_limit = 0
        use_32_bit_worker = false
    }

    app_setings = {
        "AzureWebJobsStorage" = azurerm_storage_account.Storage.primary_connection_string
        "EVENT_GRID_SCHEMA_VALIDATION" = "true"
        "COSMOS_TABLE_CONN_STRING" = azurerm_cosmosdb_account.cosmos.connection_strings[0]
        "COSMOS_TABLE_NAME" = azurerm_cosmodb_table.filemeta.name
    }
   
 }
