terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.30.0"
      # version = "1.43.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.0-pre2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }

  }
}