provider "azurerm" {
  features {}
}

# 1. Resource Group
data "azurerm_resource_group" "existing_rg" {
  name = "EY-RG"
}

# 2. Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  location            = data.azurerm_resource_group.existing_rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

# 3. AKS Cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  dns_prefix          = "ey-aks"

  # Define the default node pool
  default_node_pool {
    name       = "system"
    node_count = 2
    vm_size    = "Standard_B2ms"
  }

  #  Enable Managed Identity for the AKS cluster
  identity {
    type = "SystemAssigned"
  }

  #  Enable monitoring with Log Analytics
  oms_agent {
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id
  }

  #Enable RBAC for the cluster to enhance security by managing access.
  role_based_access_control_enabled = true
}

# 4. AKS → ACR Role Assignment
resource "azurerm_role_assignment" "aks_acr_pull" {
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

# 5. Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = var.key_vault_name
  location                    = data.azurerm_resource_group.existing_rg.location
  resource_group_name         = data.azurerm_resource_group.existing_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7
}

data "azurerm_client_config" "current" {}


# 7. Log Analytics Workspace for AKS Monitoring
resource "azurerm_log_analytics_workspace" "law" {
  name                = "ey-aks-law"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

# 8. Application Insights for monitoring applications deployed in AKS
resource "azurerm_application_insights" "appinsights" {
  name                = "ey-app-insights"
  location            = data.azurerm_resource_group.existing_rg.location
  resource_group_name = data.azurerm_resource_group.existing_rg.name
  application_type    = "web"
}
