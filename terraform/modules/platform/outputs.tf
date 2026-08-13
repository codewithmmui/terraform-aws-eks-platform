output "workload_role_arns" {
  value = {
    for k, v in aws_iam_role.workload : k => v.arn
  }
}
