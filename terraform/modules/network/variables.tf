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

variable "nsg_id" {
  type        = string
  description = "ID of the NSG to associate with subnets"
}
