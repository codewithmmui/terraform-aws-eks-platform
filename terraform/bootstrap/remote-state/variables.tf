variable "aws_region" {
  type    = string
  default = "us-east-1"
}
variable "project_name" {
  type    = string
  default = "terraform-aws-eks-platform"
}
variable "bucket_name" {
  type    = string
  default = null
}
variable "force_destroy" {
  type    = bool
  default = false
}
variable "github_role_arns" {
  type    = list(string)
  default = []
}
