environment         = "dev"
location            = "centralus"
resource_group_name = "dev-gha-rg"
acr_name            = "devghaacrdemopoc"

vnet_cidr           = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"

allowed_ssh_ip = "0.0.0.0/0"
admin_username = "azureuser"

instance_count          = 1
min_instance_count      = 1
max_instance_count      = 3
scale_out_cpu_threshold = 75
scale_in_cpu_threshold  = 25

image_tag = "latest"

vm_sku = "Standard_D2s_v3"
