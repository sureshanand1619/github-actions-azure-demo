variable "acr_name" {
  type        = string
  description = "Name of the Azure Container Registry (must be globally unique, alphanumeric only)"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
}
