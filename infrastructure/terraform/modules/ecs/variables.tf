variable "project_name" {}

variable "immich_version" {
  type = string
  default = "release"
}

variable "vpc_id" {}

variable "private_subnet_ids" {}

variable "retention_in_days" {
  default = 30
}

variable "exec_logs_retention_in_days" {
  default = 7
}

variable "app_desired_count" {
  description = "Desired number of App Tasks"
  type        = number
  default     = 2
}

variable "ml_desired_count" {
  description = "Desired number of ML Tasks"
  type = number
  default = 2
}

variable "cloudwatch_logs_key_arn" {}

variable "db_password_secret_arn" {}

variable "secrets_manager_key_arn" {}

variable "efs_file_system_id" {}

variable "efs_access_point_id" {}