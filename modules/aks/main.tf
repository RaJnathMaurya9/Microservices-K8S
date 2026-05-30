resource "azurerm_kubernetes_cluster" "aks" {
  for_each = var.clusters

  name                = each.key
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  dns_prefix          = each.value.dns_prefix
  kubernetes_version  = each.value.kubernetes_version
  tags                = each.value.tags

  default_node_pool {
    name                = each.value.default_node_pool.name
    node_count          = each.value.default_node_pool.node_count
    vm_size             = each.value.default_node_pool.vm_size
    type                = each.value.default_node_pool.type
    enable_auto_scaling = each.value.default_node_pool.enable_auto_scaling
    min_count           = each.value.default_node_pool.min_count
    max_count           = each.value.default_node_pool.max_count
    vnet_subnet_id      = each.value.default_node_pool.vnet_subnet_id
  }

  identity {
    type         = each.value.identity.type
    identity_ids = each.value.identity.identity_ids
  }

  dynamic "network_profile" {
    for_each = each.value.network_profile != null ? [each.value.network_profile] : []
    content {
      network_plugin    = network_profile.value.network_plugin
      load_balancer_sku = network_profile.value.load_balancer_sku
      network_policy    = network_profile.value.network_policy
      dns_service_ip    = network_profile.value.dns_service_ip
      service_cidr      = network_profile.value.service_cidr
    }
  }

  dynamic "ingress_application_gateway" {
    for_each = each.value.ingress_application_gateway != null ? [each.value.ingress_application_gateway] : []
    content {
      gateway_id   = ingress_application_gateway.value.gateway_id
      gateway_name = ingress_application_gateway.value.gateway_name
      subnet_cidr  = ingress_application_gateway.value.subnet_cidr
      subnet_id    = ingress_application_gateway.value.subnet_id
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = each.value.key_vault_secrets_provider != null ? [each.value.key_vault_secrets_provider] : []
    content {
      secret_rotation_enabled  = key_vault_secrets_provider.value.secret_rotation_enabled
      secret_rotation_interval = key_vault_secrets_provider.value.secret_rotation_interval
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "extra_pools" {
  for_each = merge([
    for cluster_name, cluster in var.clusters : {
      for pool_name, pool in cluster.extra_node_pools :
      "${cluster_name}-${pool_name}" => merge(pool, { cluster_id = azurerm_kubernetes_cluster.aks[cluster_name].id, name = pool_name })
    }
  ]...)

  name                  = each.value.name
  kubernetes_cluster_id = each.value.cluster_id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  vnet_subnet_id        = each.value.vnet_subnet_id
  enable_auto_scaling   = each.value.enable_auto_scaling
  min_count             = each.value.min_count
  max_count             = each.value.max_count
}
