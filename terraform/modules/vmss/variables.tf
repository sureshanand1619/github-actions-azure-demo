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

variable "vm_sku" {
  type        = string
  description = "VM SKU for VMSS instances"
  default     = "Standard_B1s"
}

variable "instance_count" {
  type        = number
  description = "Initial number of instances"
}

variable "min_instance_count" {
  type        = number
  description = "Minimum number of instances"
}

variable "max_instance_count" {
  type        = number
  description = "Maximum number of instances"
}

variable "scale_out_cpu_threshold" {
  type        = number
  description = "CPU threshold to scale out"
}

variable "scale_in_cpu_threshold" {
  type        = number
  description = "CPU threshold to scale in"
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

variable "subnet_id" {
  type        = string
  description = "Subnet ID for VMSS instances"
}

variable "backend_pool_id" {
  type        = string
  description = "Load balancer backend pool ID"
}

variable "acr_login_server" {
  type        = string
  description = "ACR login server URL"
}

variable "acr_username" {
  type        = string
  description = "ACR admin username"
  sensitive   = true
}

variable "acr_password" {
  type        = string
  description = "ACR admin password"
  sensitive   = true
}

variable "image_tag" {
  type        = string
  description = "Docker image tag to deploy"
  default     = "latest"
}
