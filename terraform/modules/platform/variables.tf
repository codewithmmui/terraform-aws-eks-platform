variable "cluster_name" {
  type = string
}
variable "oidc_provider_arn" {
  type = string
}
variable "oidc_provider_url" {
  type = string
}
variable "region" {
  type = string
}
variable "route53_zone_arns" {
  type    = list(string)
  default = []
}
variable "external_secrets_secret_arns" {
  type    = list(string)
  default = []
}
variable "enable_external_dns" {
  type    = bool
  default = false
}
variable "tags" {
  type    = map(string)
  default = {}
}
