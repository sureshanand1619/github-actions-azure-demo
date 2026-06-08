module "rg" {
  source              = "../../modules/rg"
  resource_group_name = var.resource_group_name
  location            = var.location
  environment         = var.environment
}

module "nsg" {
  source              = "../../modules/nsg"
  environment         = var.environment
  location            = var.location
  resource_group_name = module.rg.resource_group_name
  allowed_ssh_ip      = var.allowed_ssh_ip
}

module "network" {
  source              = "../../modules/network"
  environment         = var.environment
  location            = var.location
  resource_group_name = module.rg.resource_group_name
  vnet_cidr           = var.vnet_cidr
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  nsg_id              = module.nsg.nsg_id
}

module "acr" {
  source              = "../../modules/acr"
  acr_name            = var.acr_name
  resource_group_name = module.rg.resource_group_name
  location            = var.location
  environment         = var.environment
}

resource "azurerm_public_ip" "lb" {
  name                = "${var.environment}-lb-pip"
  location            = var.location
  resource_group_name = module.rg.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "this" {
  name                = "${var.environment}-lb"
  location            = var.location
  resource_group_name = module.rg.resource_group_name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.lb.id
  }
}

resource "azurerm_lb_backend_address_pool" "this" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "${var.environment}-backend-pool"
}

resource "azurerm_lb_probe" "this" {
  loadbalancer_id = azurerm_lb.this.id
  name            = "http-probe"
  port            = 80
}

resource "azurerm_lb_rule" "this" {
  loadbalancer_id                = azurerm_lb.this.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicIPAddress"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this.id]
  probe_id                       = azurerm_lb_probe.this.id
}

module "vmss" {
  source                  = "../../modules/vmss"
  environment             = var.environment
  location                = var.location
  resource_group_name     = module.rg.resource_group_name
  instance_count          = var.instance_count
  min_instance_count      = var.min_instance_count
  max_instance_count      = var.max_instance_count
  scale_out_cpu_threshold = var.scale_out_cpu_threshold
  scale_in_cpu_threshold  = var.scale_in_cpu_threshold
  admin_username          = var.admin_username
  admin_password          = var.admin_password
  subnet_id               = module.network.public_subnet_id
  backend_pool_id         = azurerm_lb_backend_address_pool.this.id
  acr_login_server        = module.acr.acr_login_server
  acr_username            = module.acr.acr_admin_username
  acr_password            = module.acr.acr_admin_password
  image_tag               = var.image_tag
  vm_sku                  = var.vm_sku # add this line
}
