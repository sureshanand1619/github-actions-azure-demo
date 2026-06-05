environment         = "prod"
location            = "centralus"
resource_group_name = "prod-gha-rg"
acr_name            = "prodghaacrdemopoc"

vnet_cidr           = "10.2.0.0/16"
public_subnet_cidr  = "10.2.1.0/24"
private_subnet_cidr = "10.2.2.0/24"

allowed_ssh_ip = "0.0.0.0/0"
admin_username = "azureuser"

instance_count          = 3
min_instance_count      = 3
max_instance_count      = 10
scale_out_cpu_threshold = 70
scale_in_cpu_threshold  = 20

image_tag = "latest"
