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