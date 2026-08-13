variable "github_org" {
  type = string
}
variable "github_repository" {
  type = string
}
variable "branch" {
  type    = string
  default = "main"
}
variable "environment" {
  type = string
}
variable "create_provider" {
  type    = bool
  default = true
}
variable "oidc_provider_arn" {
  type    = string
  default = null
}
variable "plan_policy_arns" {
  type    = set(string)
  default = []
}
variable "apply_policy_arns" {
  type    = set(string)
  default = []
}
variable "tags" {
  type    = map(string)
  default = {}
}
