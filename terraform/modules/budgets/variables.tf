variable "enabled" {
  type    = bool
  default = false
}
variable "name" {
  type = string
}
variable "monthly_limit" {
  type    = number
  default = 100
}
variable "alert_threshold" {
  type    = number
  default = 80
}
variable "notification_email" {
  type    = string
  default = null
}
