resource "azurerm_subnet" "pubsubnet" {
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    for_each = {for s in var.pubsubnets : s.name => s}
    name = each.value.name
    address_prefixes = [each.value.address_prefix]
}

resource "azurerm_route_table" "route1" {
  name                = "demo-app-public-rt"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name           = "route1"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "pubsubnet-association" {
  subnet_id      = azurerm_subnet.pubsubnet.id
  route_table_id = azurerm_route_table.route1.id
}

  

resource "azurerm_subnet" "pvtsubnet" {
    resource_group_name = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet.name
    for_each = {for s in var.pvtsubnets : s.name => s}
    name = each.value.name
    address_prefixes = [each.value.address_prefix]
  
}

resource "azurerm_public_ip" "ip1" {
    name = "static_ip1"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    allocation_method = "Static"
    sku = "Standard"
  
}

resource "azurerm_public_ip" "ip2" {
    name = "static_ip2"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    allocation_method = "Static"
    sku = "Standard"
  
}

resource "azurerm_public_ip" "ip2" {
    name = "static_ip2"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    allocation_method = "Static"
    sku = "Standard"
  
}

resource "azurerm_nat_gateway" "nat1" {
  name                = "natgateway1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_nat_gateway_public_ip_association" "pubgate1" {
  nat_gateway_id = azurerm_nat_gateway.nat1.id
  public_ip_address_id = azurerm_public_ip.ip1.id
}

resource "azurerm_subnet_nat_gateway_association" "subgate1" {
  subnet_id      = azurerm_subnet.pvtsubnet.id
  nat_gateway_id = azurerm_nat_gateway.nat1.id
  
}

resource "azurerm_nat_gateway" "nat2" {
  name                = "natgateway2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_nat_gateway_public_ip_association" "pubgate2" {
  nat_gateway_id = azurerm_nat_gateway.nat2.id
  public_ip_address_id = azurerm_public_ip.ip2.id
}

resource "azurerm_subnet_nat_gateway_association" "subgate2" {
  subnet_id      = azurerm_subnet.pvtsubnet.id
  nat_gateway_id = azurerm_nat_gateway.nat2.id
  
}

resource "azurerm_nat_gateway" "nat3" {
  name                = "natgateway3"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_nat_gateway_public_ip_association" "pubgate3" {
  nat_gateway_id = azurerm_nat_gateway.nat3.id
  public_ip_address_id = azurerm_public_ip.ip3.id
}

resource "azurerm_subnet_nat_gateway_association" "subgate3" {
  subnet_id      = azurerm_subnet.pvtsubnet.id
  nat_gateway_id = azurerm_nat_gateway.nat3.id
  
}


resource "azurerm_route_table" "private-rt-1" {
  name                = "demo-app-private-rt"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name           = "route1"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualNetworkGateway"
  }
}

resource "azurerm_subnet_route_table_association" "pubsubnet-association1" {
  subnet_id      = azurerm_subnet.pvtsubnet.id
  route_table_id = azurerm_route_table.private-rt-1.id
}

resource "azurerm_route_table" "private-rt-2" {
  name                = "demo-app-private-rt2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name           = "route1"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualNetworkGateway"
  }
}

resource "azurerm_subnet_route_table_association" "pubsubnet-association2" {
  subnet_id      = azurerm_subnet.pvtsubnet.id
  route_table_id = azurerm_route_table.private-rt-2.id
}

resource "azurerm_route_table" "private-rt-3" {
  name                = "demo-app-private-rt3"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  route {
    name           = "route1"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualNetworkGateway"
  }
}

resource "azurerm_subnet_route_table_association" "pubsubnet-association3" {
  subnet_id      = azurerm_subnet.pvtsubnet.id
  route_table_id = azurerm_route_table.private-rt-3.id
}