locals {
  common_tags = {
    Project = var.project_name, Environment = var.environment, ManagedBy = "Terraform", Owner = var.owner, Repository = var.github_repository, CostCenter = var.cost_center
  }
}
module "vpc" {
  source               = "../../modules/vpc"
  project_name         = var.project_name
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  enable_nat_gateway   = var.enable_nat_gateway
  single_nat_gateway   = var.single_nat_gateway
  tags                 = local.common_tags
}
module "iam" {
  source       = "../../modules/iam"
  project_name = var.project_name
  environment  = var.environment
  tags         = local.common_tags
}
module "eks" {
  source                    = "../../modules/eks"
  cluster_name              = var.cluster_name
  kubernetes_version        = var.kubernetes_version
  cluster_role_arn          = module.iam.cluster_role_arn
  subnet_ids                = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)
  endpoint_private_access   = true
  endpoint_public_access    = var.endpoint_public_access
  public_access_cidrs       = var.public_access_cidrs
  enabled_cluster_log_types = var.enabled_cluster_log_types
  log_retention_days        = var.log_retention_days
  admin_principal_arn       = var.admin_principal_arn
  tags                      = local.common_tags
  depends_on                = [module.iam]
}
module "node_groups" {
  source        = "../../modules/node-groups"
  cluster_name  = module.eks.cluster_name
  node_role_arn = module.iam.node_role_arn
  subnet_ids    = module.vpc.private_subnet_ids
  node_groups   = var.node_groups
  tags          = local.common_tags
  depends_on    = [module.eks, module.iam]
}
module "platform" {
  source              = "../../modules/platform"
  cluster_name        = module.eks.cluster_name
  oidc_provider_arn   = module.eks.oidc_provider_arn
  oidc_provider_url   = module.eks.oidc_provider_url
  region              = var.aws_region
  enable_external_dns = var.enable_external_dns
  route53_zone_arns   = var.route53_zone_arns
  tags                = local.common_tags
  depends_on          = [module.node_groups]
}
module "ecr" {
  source           = "../../modules/ecr"
  repository_names = var.ecr_repositories
  tags             = local.common_tags
}
module "github_oidc" {
  count             = var.create_github_oidc ? 1 : 0
  source            = "../../modules/github-oidc"
  github_org        = var.github_org
  github_repository = var.github_repository
  branch            = var.github_branch
  environment       = var.environment
  plan_policy_arns  = var.github_plan_policy_arns
  apply_policy_arns = var.github_apply_policy_arns
  tags              = local.common_tags
}
module "budget" {
  source             = "../../modules/budgets"
  enabled            = var.create_budget
  name               = "${var.project_name}-${var.environment}"
  monthly_limit      = var.monthly_budget
  notification_email = var.budget_alert_email
}
