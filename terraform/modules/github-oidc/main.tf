data "tls_certificate" "github" {
  count = var.create_provider ? 1 : 0
  url   = "https://token.actions.githubusercontent.com"
}
resource "aws_iam_openid_connect_provider" "github" {
  count           = var.create_provider ? 1 : 0
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github[0].certificates[0].sha1_fingerprint]
  tags            = var.tags
}
locals {
  provider_arn = var.create_provider ? aws_iam_openid_connect_provider.github[0].arn : var.oidc_provider_arn
  subject      = "repo:${var.github_org}/${var.github_repository}:*"
}
data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [local.provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [local.subject]
    }
  }
}
resource "aws_iam_role" "plan" {
  name               = "github-${var.github_repository}-${var.environment}-plan"
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags               = var.tags
}
resource "aws_iam_role" "apply" {
  name               = "github-${var.github_repository}-${var.environment}-apply"
  assume_role_policy = data.aws_iam_policy_document.trust.json
  tags               = var.tags
}
resource "aws_iam_role_policy_attachment" "plan" {
  for_each   = var.plan_policy_arns
  role       = aws_iam_role.plan.name
  policy_arn = each.value
}
resource "aws_iam_role_policy_attachment" "apply" {
  for_each   = var.apply_policy_arns
  role       = aws_iam_role.apply.name
  policy_arn = each.value
}
