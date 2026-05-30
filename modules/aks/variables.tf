variable "clusters" {
  description = "A map of AKS clusters to create"
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
