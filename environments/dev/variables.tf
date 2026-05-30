variable "resource_groups" {
  type = map(object({
    location = string
    tags     = optional(map(string), {})
  }))
}

variable "registries" {
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

variable "clusters" {
  type = map(object({
    resource_group_name = string
    location           = string
    dns_prefix         = string
    kubernetes_version = optional(string)
    tags               = optional(map(string), {})

    default_node_pool = object({
      name       = string
      node_count = number
      vm_size    = string
      type       = optional(string, "VirtualMachineScaleSets")
      enable_auto_scaling = optional(bool, false)
      min_count          = optional(number)
      max_count          = optional(number)
      vnet_subnet_id     = optional(string)
    })

    identity = object({
      type         = string
      identity_ids = optional(list(string))
    })

    network_profile = optional(object({
      network_plugin    = optional(string, "kubenet")
      load_balancer_sku = optional(string, "standard")
      network_policy    = optional(string)
      dns_service_ip    = optional(string)
      service_cidr      = optional(string)
    }))

    ingress_application_gateway = optional(object({
      gateway_id   = optional(string)
      gateway_name = optional(string)
      subnet_cidr  = optional(string)
      subnet_id    = optional(string)
    }))

    key_vault_secrets_provider = optional(object({
      secret_rotation_enabled  = optional(bool, false)
      secret_rotation_interval = optional(string, "2m")
    }))

    extra_node_pools = optional(map(object({
      vm_size    = string
      node_count = number
      vnet_subnet_id = optional(string)
      enable_auto_scaling = optional(bool, false)
      min_count = optional(number)
      max_count = optional(number)
    })), {})
  }))
}
