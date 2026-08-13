# Reserved for AWS-native observability resources (AMP/AMG) without coupling
# the base platform to their cost. Kubernetes monitoring is configured under helm/monitoring.
locals {
  component_name = var.name
}
