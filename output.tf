
output "location" {
    description = "Location your servers are deployed at"
    value = azurerm_resource_group.main.location
}

output "main_public_ip" {
    description = "The name of the loadbalancer_id"
    value = azurerm_public_ip.main.ip_address
}
