terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "POC"
    storage_account_name = "tfstatepoc2026"
    container_name       = "tfstate"
    key                  = "dev/gha-demo.tfstate"
  }
}

provider "azurerm" {
  features {}
}
