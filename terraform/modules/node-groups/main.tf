resource "aws_eks_node_group" "this" {
  for_each        = var.node_groups
  cluster_name    = var.cluster_name
  node_group_name = each.key
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  instance_types  = each.value.instance_types
  capacity_type   = each.value.capacity_type
  disk_size       = each.value.disk_size
  scaling_config {
    desired_size = each.value.desired_size
    min_size     = each.value.min_size
    max_size     = each.value.max_size
  }
  update_config {
    max_unavailable_percentage = 25
  }
  labels = each.value.labels
  dynamic "taint" {
    for_each = each.value.taints
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
  tags = merge(var.tags, {
    Name = "${var.cluster_name}-${each.key}"
  })
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
