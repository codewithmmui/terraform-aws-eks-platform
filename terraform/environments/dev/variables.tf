variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "project_name" {
  type    = string
  default = "terraform-aws-eks-platform"
}
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}
variable "vpc_cidr" {
  type = string
}
variable "availability_zones" {
  type = list(string)
}
variable "public_subnet_cidrs" {
  type = list(string)
}
variable "private_subnet_cidrs" {
  type = list(string)
}
variable "enable_nat_gateway" {
  type    = bool
  default = true
}
variable "single_nat_gateway" {
  type    = bool
  default = true
}
variable "cluster_name" {
  type = string
}
variable "kubernetes_version" {
  type    = string
  default = null
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
  default = 7
}
variable "admin_principal_arn" {
  type = string
  validation {
    condition     = can(regex("^arn:aws(-[a-z]+)?:iam::[0-9]{12}:role/.+", var.admin_principal_arn))
    error_message = "admin_principal_arn must be an IAM role ARN (not a user or STS session ARN)."
  }
}
variable "node_groups" {
  type = map(object({
    instance_types = list(string), capacity_type = string, desired_size = number, min_size = number, max_size = number, disk_size = number, labels = map(string), taints = optional(list(object({
      key = string, value = optional(string), effect = string
    })), [])
  }))
}
variable "ecr_repositories" {
  type    = set(string)
  default = ["frontend", "backend", "test-app"]
}
variable "enable_external_dns" {
  type    = bool
  default = false
}
variable "route53_zone_arns" {
  type    = list(string)
  default = []
}
variable "github_org" {
  type    = string
  default = null
}
variable "github_repository" {
  type    = string
  default = "terraform-aws-eks-platform"
}
variable "github_branch" {
  type    = string
  default = "main"
}
variable "github_plan_policy_arns" {
  type    = set(string)
  default = []
}
variable "github_apply_policy_arns" {
  type    = set(string)
  default = []
}
variable "create_github_oidc" {
  type    = bool
  default = false
}
variable "create_budget" {
  type    = bool
  default = false
}
variable "monthly_budget" {
  type    = number
  default = 100
}
variable "budget_alert_email" {
  type    = string
  default = null
}
variable "owner" {
  type    = string
  default = "platform-team"
}
variable "cost_center" {
  type    = string
  default = "engineering"
}
