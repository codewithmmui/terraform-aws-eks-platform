resource "aws_budgets_budget" "this" {
  count        = var.enabled ? 1 : 0
  name         = var.name
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_limit)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  dynamic "notification" {
    for_each = var.notification_email == null ? [] : [1]
    content {
      comparison_operator        = "GREATER_THAN"
      threshold                  = var.alert_threshold
      threshold_type             = "PERCENTAGE"
      notification_type          = "FORECASTED"
      subscriber_email_addresses = [var.notification_email]
    }
  }
}
