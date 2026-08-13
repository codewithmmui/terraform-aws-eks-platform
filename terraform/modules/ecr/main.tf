resource "aws_ecr_repository" "this" {
  for_each             = var.repository_names
  name                 = each.value
  image_tag_mutability = var.image_tag_mutability
  encryption_configuration {
    encryption_type = "AES256"
  }
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = var.tags
}
resource "aws_ecr_lifecycle_policy" "this" {
  for_each   = aws_ecr_repository.this
  repository = each.value.name
  policy = jsonencode({
    rules = [{
      rulePriority = 1, description = "Expire old untagged images", selection = {
        tagStatus = "untagged", countType = "sinceImagePushed", countUnit = "days", countNumber = var.untagged_expiry_days
        }, action = {
        type = "expire"
      }
    }]
  })
}
