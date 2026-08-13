output "state_bucket_name" {
  value = aws_s3_bucket.state.id
}
output "backend_example" {
  value = "bucket = \"${aws_s3_bucket.state.id}\"\nregion = \"${var.aws_region}\"\nuse_lockfile = true\nencrypt = true"
}
