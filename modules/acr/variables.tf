variable "registries" {
  description = "A map of Azure Container Registries to create"
  type = map(object({
    resource_group_name = string
    location           = string
    sku                = optional(string, "Standard")
    admin_enabled      = optional(bool, false)
    tags               = optional(map(string), {})
    
    georeplications = optional(list(object({
      location                  = string
      regional_endpoint_enabled = optional(bool, true)
      zone_redundancy_enabled   = optional(bool, false)
      tags                      = optional(map(string), {})
    })), [])

    network_rule_set = optional(object({
      default_action = optional(string, "Allow")
      ip_rule = optional(list(object({
        action   = string
        ip_range = string
      })), [])
    }))
  }))
}
