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

variable "sm_deletion_window_in_days" {
  type = number
}

variable "cloudwatch_deletion_window_in_days" {
  type = number
}

variable "efs_deletion_window_in_days" {
  type = number
}

variable "rds_deletion_window_in_days" {
  type = number
}

variable "backup_schedule" {
  type        = string
  description = "Cron for backup schedule"
}

variable "notification_email" {
  type        = string
  description = "Your EMAIL for SNS Alerts"
}

variable "dns_ttl" {
  type = number
  description = "TTL (Time To Live) for DNS records in seconds"
}

variable "rds_backup_retention_period" {
  type = number
}

variable "rds_preferred_backup_window" {
  type = string
}

variable "rds_preferred_maintenance_window" {
  type = string
}