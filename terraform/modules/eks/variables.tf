variable "cluster_name" {
  type = string
}
variable "kubernetes_version" {
  type    = string
  default = null
}
variable "cluster_role_arn" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "endpoint_private_access" {
  type    = bool
  default = true
}
variable "endpoint_public_access" {
  type    = bool
  default = false
}
variable "public_access_cidrs" {
  type    = list(string)
  default = []
}
variable "enabled_cluster_log_types" {
  type    = list(string)
  default = ["api", "audit", "authenticator"]
}
variable "log_retention_days" {
  type    = number
  default = 30
}
variable "kms_key_arn" {
  type    = string
  default = null
}
variable "admin_principal_arn" {
  type    = string
  default = null
}
variable "tags" {
  type    = map(string)
  default = {}
}
