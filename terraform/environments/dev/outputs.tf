output "cluster_name" {
  value = module.eks.cluster_name
}
output "cluster_arn" {
  value = module.eks.cluster_arn
}
output "cluster_endpoint" {
  value     = module.eks.cluster_endpoint
  sensitive = true
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "ecr_repository_urls" {
  value = module.ecr.repository_urls
}
output "workload_role_arns" {
  value = module.platform.workload_role_arns
}
output "github_roles" {
  value = var.create_github_oidc ? {
    plan = module.github_oidc[0].plan_role_arn, apply = module.github_oidc[0].apply_role_arn
  } : null
}
