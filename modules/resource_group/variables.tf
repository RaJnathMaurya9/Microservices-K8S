variable "resource_groups" {
  description = "A map of resource groups to create"
  type = map(object({
    location = string
    tags     = optional(map(string), {})
  }))
}
