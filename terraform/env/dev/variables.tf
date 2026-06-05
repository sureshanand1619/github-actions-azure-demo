variable "environment" {
  type        = string
  description = "Deployment environment"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "acr_name" {
  type        = string
  description = "Azure Container Registry name (globally unique, alphanumeric only)"
}

variable "vnet_cidr" {
  type        = string
  description = "CIDR block for the virtual network"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public subnet"
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR block for the private subnet"
}

variable "allowed_ssh_ip" {
  type        = string
  description = "CIDR block allowed for SSH access"
}

variable "admin_username" {
  type        = string
  description = "Admin username for VMSS instances"
}

variable "admin_password" {
  type        = string
  description = "Admin password for VMSS instances"
  sensitive   = true
}

variable "instance_count" {
  type        = number
  description = "Initial number of VMSS instances"
}

variable "min_instance_count" {
  type        = number
  description = "Minimum number of VMSS instances"
}

variable "max_instance_count" {
  type        = number
  description = "Maximum number of VMSS instances"
}

variable "scale_out_cpu_threshold" {
  type        = number
  description = "CPU threshold to scale out"
}

variable "scale_in_cpu_threshold" {
  type        = number
  description = "CPU threshold to scale in"
}

variable "image_tag" {
  type        = string
  description = "Docker image tag to deploy"
  default     = "latest"
}

variable "vm_sku" {
  type        = string
  description = "VM SKU for VMSS instances"
  default     = "Standard_B2s"
}
