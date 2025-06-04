variable "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  type        = string
  default     = "loganalyticsworkspace"
}
variable "aks_container_insights_enabled" {
  description = "Enable AKS Container Insights"
  type        = bool
  default     = true
}

variable "azurerm_kubernetes_cluster_name" {
  description = "Name of the AKS Cluster"
  type        = string
  default     = "tee-testr"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.31.1"

}
variable "agent_pool_profile_vm_size" {
  description = "VM size for the agent pool"
  type        = string
  default     = "Standard_DS2_v2"

}
variable "admin_username" {
  description = "Admin username for the AKS cluster"
  type        = string
  default     = "adminuser"

}
variable "admin_password" {
  description = "Admin password for the AKS cluster"
  type        = string
  default     = "xxxxxxxxxxxxxx"
  sensitive   = true
}

# variable "public_ssh_key" {
#   description = "Public SSH key for the AKS cluster"
#   type        = string
#   default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC4"
#   }
variable "ssh_public_key" {
  description = "SSH public key for the AKS cluster"
  type        = string
  default     = "xxxx"
}

variable "aks_admins_aad_group_name" {
  description = "Name of the AAD group for AKS admins"
  type        = string
  default     = "aks-admins"
}

variable "tags" {
  description = "Tag for the resources"
  type        = string
  default     = "teeworks"
}

variable "location" {
  description = "Location for the resources"
  type        = string
  default     = "westeurope"
}

variable "azure_resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "tee-aks-rg"
}