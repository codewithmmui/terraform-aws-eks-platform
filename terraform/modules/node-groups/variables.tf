variable "cluster_name" {
  type = string
}
variable "node_role_arn" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "node_groups" {
  type = map(object({
    instance_types = list(string), capacity_type = string, desired_size = number, min_size = number, max_size = number, disk_size = number, labels = map(string), taints = optional(list(object({
      key = string, value = optional(string), effect = string
    })), [])
  }))
}
variable "tags" {
  type    = map(string)
  default = {}
}
