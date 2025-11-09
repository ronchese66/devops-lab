variable "project_name" {
  type = string
}

variable "aws_region" {
  type = string
}

variable "aws_profile" {
  type = string
}

variable "enable_key_rotation" {
  type        = bool
  description = "Enable key rotation every month"
}

variable "deletion_window_in_days" {
  type = number
}