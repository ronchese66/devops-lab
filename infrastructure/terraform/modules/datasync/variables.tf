variable "project_name" {}

variable "efs_file_system_arn" {}

variable "efs_mount_target_sg_arn" {}

variable "private_subnet_arns" {}

variable "backup_schedule" {}

variable "notification_email" {
  type = string
}