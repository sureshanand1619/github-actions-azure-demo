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

variable "allowed_ssh_ip" {
  type        = string
  description = "CIDR block allowed for SSH access"
}
