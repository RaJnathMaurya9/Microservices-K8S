resource "azurerm_container_registry" "acr" {
  for_each = var.registries

  name                = each.key
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  sku                 = each.value.sku
  admin_enabled       = each.value.admin_enabled
  tags                = each.value.tags

  dynamic "georeplications" {
    for_each = each.value.georeplications
    content {
      location                  = georeplications.value.location
      regional_endpoint_enabled = georeplications.value.regional_endpoint_enabled
      zone_redundancy_enabled   = georeplications.value.zone_redundancy_enabled
      tags                      = georeplications.value.tags
    }
  }

  dynamic "network_rule_set" {
    for_each = each.value.network_rule_set != null ? [each.value.network_rule_set] : []
    content {
      default_action = network_rule_set.value.default_action
      
      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rule
        content {
          action   = ip_rule.value.action
          ip_range = ip_rule.value.ip_range
        }
      }
    }
  }
}
