variable "min_capacity" {
  default = 0.5
}

variable "max_capacity" {
  default = 2
}

variable "project_name" {}

variable "vpc_id" {}

variable "private_subnet_ids" {}

variable "vpc_cidr" {}

variable "ecs_app_sg_id" {}

variable "db_password_value" {}

variable "rds_key_arn" {}

variable "rds_backup_retention_period" {}

variable "rds_preferred_backup_window" {}

variable "rds_preferred_maintenance_window" {}

variable "rds_retention_in_days" {
  default = 7
}

variable "cloudwatch_logs_key_arn" {}
