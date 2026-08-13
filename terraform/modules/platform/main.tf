locals {
  oidc_host = replace(var.oidc_provider_url, "https://", "")
}
data "aws_iam_policy_document" "irsa" {
  for_each = {
    ebs = "kube-system:ebs-csi-controller-sa", alb = "ingress-system:aws-load-balancer-controller", eso = "external-secrets:external-secrets", dns = "external-dns:external-dns"
  }
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["system:serviceaccount:${each.value}"]
    }
  }
}
resource "aws_iam_role" "workload" {
  for_each           = data.aws_iam_policy_document.irsa
  name               = "${var.cluster_name}-${each.key}"
  assume_role_policy = each.value.json
  tags               = var.tags
}
resource "aws_iam_role_policy_attachment" "ebs" {
  role       = aws_iam_role.workload["ebs"].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
data "aws_iam_policy_document" "alb" {
  statement {
    actions   = ["ec2:Describe*", "elasticloadbalancing:Describe*", "elasticloadbalancing:CreateLoadBalancer", "elasticloadbalancing:CreateTargetGroup", "elasticloadbalancing:CreateListener", "elasticloadbalancing:ModifyLoadBalancerAttributes", "elasticloadbalancing:ModifyTargetGroup", "elasticloadbalancing:ModifyTargetGroupAttributes", "elasticloadbalancing:AddTags", "elasticloadbalancing:RegisterTargets", "elasticloadbalancing:DeregisterTargets", "elasticloadbalancing:DeleteListener", "elasticloadbalancing:DeleteTargetGroup", "elasticloadbalancing:DeleteLoadBalancer", "ec2:CreateSecurityGroup", "ec2:AuthorizeSecurityGroupIngress", "ec2:RevokeSecurityGroupIngress", "ec2:DeleteSecurityGroup", "ec2:CreateTags", "iam:CreateServiceLinkedRole", "cognito-idp:DescribeUserPoolClient", "acm:ListCertificates", "acm:DescribeCertificate", "waf-regional:GetWebACLForResource", "wafv2:GetWebACLForResource", "shield:GetSubscriptionState"]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "alb" {
  name   = "${var.cluster_name}-alb-controller"
  policy = data.aws_iam_policy_document.alb.json
  tags   = var.tags
}
resource "aws_iam_role_policy_attachment" "alb" {
  role       = aws_iam_role.workload["alb"].name
  policy_arn = aws_iam_policy.alb.arn
}
data "aws_iam_policy_document" "eso" {
  statement {
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = length(var.external_secrets_secret_arns) > 0 ? var.external_secrets_secret_arns : ["arn:aws:secretsmanager:${var.region}:*:secret:${var.cluster_name}/*"]
  }
}
resource "aws_iam_policy" "eso" {
  name   = "${var.cluster_name}-external-secrets"
  policy = data.aws_iam_policy_document.eso.json
  tags   = var.tags
}
resource "aws_iam_role_policy_attachment" "eso" {
  role       = aws_iam_role.workload["eso"].name
  policy_arn = aws_iam_policy.eso.arn
}
data "aws_iam_policy_document" "dns" {
  statement {
    actions   = ["route53:ListHostedZones", "route53:ListResourceRecordSets"]
    resources = ["*"]
  }
  statement {
    actions   = ["route53:ChangeResourceRecordSets"]
    resources = var.route53_zone_arns
  }
}
resource "aws_iam_policy" "dns" {
  count  = var.enable_external_dns ? 1 : 0
  name   = "${var.cluster_name}-external-dns"
  policy = data.aws_iam_policy_document.dns.json
  tags   = var.tags
}
resource "aws_iam_role_policy_attachment" "dns" {
  count      = var.enable_external_dns ? 1 : 0
  role       = aws_iam_role.workload["dns"].name
  policy_arn = aws_iam_policy.dns[0].arn
}
resource "aws_eks_addon" "ebs" {
  cluster_name                = var.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  service_account_role_arn    = aws_iam_role.workload["ebs"].arn
  resolve_conflicts_on_update = "PRESERVE"
  tags                        = var.tags
}
