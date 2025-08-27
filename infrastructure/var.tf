variable "available_locations" {
    description = "Available locations"
    type = list(string)
    default = [ "East US", "West US", "Europe" ]
  
}

variable "subnets" {
    type = list(object({
        name = string
        address_prefixes = string
    }))
       default = [
        {
            name = "public-subnet1"
            address_prefixes = "10.0.1.0/24"
        },
        {
            name = "public-subnet2"
            address_prefixes = "10.0.2.0/24"
        },
        {
            name = "public-subnet3"
            address_prefixes = "10.0.3.0/24"
        },
        {
            name = "private-subnet1"
            address_prefixes = "10.0.11.0/24"
        },
        {
            name = "private-subnet2"
            address_prefixes = "10.0.12.0/24"
        },
        {
            name = "private-subnet3"
            address_prefixes = "10.0.13.0/24"
        }
       ]   
}