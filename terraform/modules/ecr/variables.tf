variable "repository_names" {
  type = set(string)
}
variable "image_tag_mutability" {
  type    = string
  default = "IMMUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Must be MUTABLE or IMMUTABLE."
  }
}
variable "untagged_expiry_days" {
  type    = number
  default = 14
}
variable "tags" {
  type    = map(string)
  default = {}
}
