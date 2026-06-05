output "load_balancer_public_ip" {
  value = azurerm_public_ip.lb.ip_address
}

output "acr_login_server" {
  value = module.acr.acr_login_server
}

output "resource_group_name" {
  value = module.rg.resource_group_name
}
