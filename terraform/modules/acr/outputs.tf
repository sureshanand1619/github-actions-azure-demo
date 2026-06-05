output "acr_login_server" {
  value = azurerm_container_registry.this.login_server
}

output "acr_name" {
  value = azurerm_container_registry.this.name
}

output "acr_admin_username" {
  value     = azurerm_container_registry.this.admin_username
  sensitive = true
}

output "acr_admin_password" {
  value     = azurerm_container_registry.this.admin_password
  sensitive = true
}
