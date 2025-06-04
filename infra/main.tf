resource "azurerm_resource_group" "velero" {
  name     = "velerobackup"
  location = "Canada central"
}

resource "azurerm_storage_account" "velero" {
  name                     = "storageaccountnamexxx"
  resource_group_name      = "velerobackup"
  account_replication_type = "GRS"
  location                 = "canada central"
  account_tier             = "Standard"
  #https_traffic_only_enabled =  true
  account_kind    = "BlobStorage"
  access_tier     = "Hot"
  min_tls_version = "TLS1_2"
  depends_on      = [azurerm_resource_group.velero]

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "velero" {
  name                  = "vhds"
  storage_account_id    = azurerm_storage_account.velero.id
  container_access_type = "private"
}



resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "azurerm_log_analytics_workspace" "example" {
  name                = "acctest-01"
  location            = azurerm_resource_group.velero.location
  resource_group_name = azurerm_resource_group.velero.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "example" {
  name                       = "Example-Environment"
  location                   = azurerm_resource_group.velero.location
  resource_group_name        = azurerm_resource_group.velero.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

resource "azurerm_container_app" "example" {
  name                         = "example-app"
  container_app_environment_id = azurerm_container_app_environment.example.id
  resource_group_name          = azurerm_resource_group.velero.name
  revision_mode                = "Single"

  template {
    container {
      name   = "examplecontainerapp"
      image  = "mcr.microsoft.com/k8se/quickstart:latest"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}
# resource "azurerm_resource_group" "aks" {
#   name     = var.azure_resourcegroup_name
#   location = var.location
#   tags     = var.tags
# }

#Log Analytics
resource "azurerm_log_analytics_workspace" "aks" {
  count = var.aks_container_insights_enabled ? 1 : 0

  # The Workspace name is globally unique
  name                = var.log_analytics_workspace_name
  location            = "canada central"
  resource_group_name = "tee"
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags = {
    environment = "staging"
  }
}
# resource "azurerm_log_analytics_solution" "aks" {
#   count = var.aks_container_insights_enabled ? 1 : 0

#   solution_name         = "ContainerInsights"
#   location              = "canada central"
#   resource_group_name   = "tee"
#   workspace_resource_id = azurerm_log_analytics_workspace.aks[0].id
#   workspace_name        = azurerm_log_analytics_workspace.aks[0].name

#   plan {
#     publisher = "Microsoft"
#     product   = "OMSGallery/ContainerInsights"
#   }
# }

# # NOTE: Requires "Azure Active Directory Graph" "Directory.ReadWrite.All" Application API permission to create, and
# # also requires "User Access Administrator" role to delete
# # ! You can assign one of the required Azure Active Directory Roles with the AzureAD PowerShell Module
# # https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/group
# resource "azuread_group" "aks_admins" {
#   display_name            = "${var.azurerm_kubernetes_cluster_name}-aks-administrators"
#   description             = "${var.azurerm_kubernetes_cluster_name} Kubernetes cluster administrators"
#   prevent_duplicate_names = true
#   security_enabled        = true
# }

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
# resource "azurerm_kubernetes_cluster" "aks" {
#   name                              = var.azurerm_kubernetes_cluster_name
#   location                          = "canada central"
#   resource_group_name               = "tee"
#   dns_prefix                        = var.azurerm_kubernetes_cluster_name
#   kubernetes_version                = var.kubernetes_version
#   sku_tier                          = "Free"
#   role_based_access_control_enabled = true
#   tags = {
#     environment = "staging"
#   }
#   default_node_pool {
#     name                 = "default"
#     orchestrator_version = var.kubernetes_version
#     vm_size              = var.agent_pool_profile_vm_size
#     node_count           = 1
#     max_pods             = 90

#     upgrade_settings {
#       drain_timeout_in_minutes =  0
#       max_surge =  "10%"
#       node_soak_duration_in_minutes =  0
#     }
#   }

# #   linux_profile {
# #     admin_username = var.admin_username

# #     ssh_key {
# #       key_data = chomp(

# #           tls_private_key.ssh.public_key_openssh,

# #       )
# #     }
# #   }

#   # managed identity block
#   # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#identity
#   identity {
#     type = "SystemAssigned"
#   }

#   # https://docs.microsoft.com/en-us/azure/aks/azure-ad-rbac
# #   azure_active_directory_role_based_access_control {
# #     # managed = true
# #     admin_group_object_ids = [
# #       azuread_group.aks_admins.object_id
# #     ]
# #   }
#  key_vault_secrets_provider {
#    secret_rotation_enabled =  true
#    #secret_rotation_interval =  "PT1H"
#  }

#   # https://docs.microsoft.com/en-ie/azure/governance/policy/concepts/policy-for-kubernetes
#   azure_policy_enabled = false

#   # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#oms_agent
#   # conditional dynamic block
# #   dynamic "oms_agent" {
# #     for_each = var.aks_container_insights_enabled == true ? [1] : []
# #     content {
# #       log_analytics_workspace_id = azurerm_log_analytics_workspace.aks[0].id
# #     }
# #   }

#   # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#network_plugin
#   network_profile {
#     load_balancer_sku = "basic"
#     outbound_type     = "loadBalancer"
#     network_plugin    = "azure"
#     network_policy    = "azure"
#     service_cidr      = "10.0.0.0/16"
#     dns_service_ip    = "10.0.0.10"
#     # docker_bridge_cidr = "172.17.0.1/16"
#   }

#   # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#workload_identity_enabled
#   # https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster#register-the-enableworkloadidentitypreview-feature-flag
#   oidc_issuer_enabled       = true
#   workload_identity_enabled = true
# }

# Add role to access AKS Resource View
# https://docs.microsoft.com/en-us/azure/aks/kubernetes-portal
# resource "azurerm_role_assignment" "aks_portal_resource_view" {
#   principal_id         = azuread_group.aks_admins.object_id
#   role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
#   scope                = azurerm_kubernetes_cluster.aks.id
# }

#Add existing AAD group as a member to the <AKS_CLUSTER_NAME>-aks-administrators group
# data "azuread_group" "existing_aks_admins" {
#   display_name     = var.aks_admins_aad_group_name
#   security_enabled = true
# }

# resource "azuread_group_member" "existing_aks_admins" {
#   group_object_id = data.azuread_group.existing_aks_admins.object_id
#   #   member_object_id = data.azuread_group.existing_aks_admins.id
#   member_object_id = data.azuread_user.example.object_id

#   depends_on = [azurerm_role_assignment.aks_portal_resource_view]
# }

# data "azuread_user" "example" {
#   user_principal_name = "ochuko@tellenchuksgmail.onmicrosoft.com"
# }

# resource "azuread_group" "aks_admins" {
#   display_name     = "my_group"
#   security_enabled = true
# }

# resource "azuread_group_member" "example" {
#   group_object_id  = data.azuread_group.existing_aks_admins.object_id
#   member_object_id = data.azuread_user.example.object_id
# }
# resource "azurerm_role_assignment" "example" {
#   principal_id         = data.azuread_user.example.object_id
#   role_definition_name = "Reader"
#   scope                = azurerm_kubernetes_cluster.aks.id
# }


# resource "azurerm_kubernetes_cluster" "velero" {
#   name                              = "velero"
#   location                          = "canada east"
#   resource_group_name               = "velerobackup"
#   dns_prefix                        = "velero-backup"
#   kubernetes_version                = var.kubernetes_version
#   sku_tier                          = "Free"
#   role_based_access_control_enabled = true
#   tags = {
#     environment = "staging"
#   }
#   default_node_pool {
#     name                 = "default"
#     orchestrator_version = var.kubernetes_version
#     vm_size              = "Standard_D2"
#     node_count           = 1
#     max_pods             = 90

#   upgrade_settings {
#       drain_timeout_in_minutes =  0
#       max_surge =  "10%"
#       node_soak_duration_in_minutes =  0
#     }
#   }

# #   linux_profile {
# #     admin_username = var.admin_username

# #     ssh_key {
# #       key_data = chomp(

# #           tls_private_key.ssh.public_key_openssh,

# #       )
# #     }
# #   }

#   # managed identity block
#   # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#identity
#   identity {
#     type = "SystemAssigned"
#   }

#   # https://docs.microsoft.com/en-us/azure/aks/azure-ad-rbac
# #   azure_active_directory_role_based_access_control {
# #     # managed = true
# #     admin_group_object_ids = [
# #       azuread_group.aks_admins.object_id
# #     ]
# #   }

#   # https://docs.microsoft.com/en-ie/azure/governance/policy/concepts/policy-for-kubernetes
#   azure_policy_enabled = false

#   # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#oms_agent
#   # conditional dynamic block
# #   dynamic "oms_agent" {
# #     for_each = var.aks_container_insights_enabled == true ? [1] : []
# #     content {
# #       log_analytics_workspace_id = azurerm_log_analytics_workspace.aks[0].id
# #     }
# #   }

#   # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#network_plugin
#   network_profile {
#     load_balancer_sku = "basic"
#     outbound_type     = "loadBalancer"
#     network_plugin    = "azure"
#     network_policy    = "azure"
#     service_cidr      = "10.0.0.0/16"
#     dns_service_ip    = "10.0.0.10"
#     # docker_bridge_cidr = "172.17.0.1/16"
#   }

#   # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster#workload_identity_enabled
#   # https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster#register-the-enableworkloadidentitypreview-feature-flag
#   oidc_issuer_enabled       = true
#   workload_identity_enabled = true
# }

# Add role to access AKS Resource View
# https://docs.microsoft.com/en-us/azure/aks/kubernetes-portal
# resource "azurerm_role_assignment" "aks_portal_resource_view" {
#   principal_id         = azuread_group.aks_admins.object_id
#   role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
#   scope                = azurerm_kubernetes_cluster.aks.id
# }

# Add existing AAD group as a member to the <AKS_CLUSTER_NAME>-aks-administrators group
# data "azuread_group" "existing_aks_admins" {
#   display_name     = var.aks_admins_aad_group_name
#   security_enabled = true
# }

# resource "azuread_group_member" "existing_aks_admins" {
#   group_object_id = azuread_group.example.id
#   #   member_object_id = data.azuread_group.existing_aks_admins.id
#   member_object_id = data.azuread_group.existing_aks_admins.object_id

#   depends_on = [azurerm_role_assignment.aks_portal_resource_view]
# }

# data "azuread_user" "example" {
#   user_principal_name = "ochuko@tellenchuksgmail.onmicrosoft.com"
# }

# resource "azuread_group" "aks_admins" {
#   display_name     = "my_group"
#   security_enabled = true
# }

# resource "azuread_group_member" "example" {
#   group_object_id  = azuread_group.example.object_id
#   member_object_id = data.azuread_user.example.object_id
# }
# resource "azurerm_role_assignment" "example" {
#   principal_id         = data.azuread_user.example.object_id
#   role_definition_name = "Reader"
#   scope                = azurerm_kubernetes_cluster.aks.id
# }