output "budget_id" {
  value = try(aws_budgets_budget.this[0].id, null)
}
