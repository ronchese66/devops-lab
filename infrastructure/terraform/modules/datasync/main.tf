resource "aws_datasync_location_efs" "datasync_source" {
  efs_file_system_arn = var.efs_file_system_arn

  ec2_config {
    security_group_arns = [var.efs_mount_target_sg_arn]
    subnet_arn          = var.private_subnet_arns[0]
  }

  tags = {
    Name = "${var.project_name}-EFS-Source-Location"
  }
}

resource "aws_datasync_location_s3" "datasync_destination" {
  s3_bucket_arn    = aws_s3_bucket.backup_bucket.arn
  subdirectory     = "/"
  s3_storage_class = "INTELLIGENT_TIERING"

  s3_config {
    bucket_access_role_arn = aws_iam_role.datasync_role.arn
  }

  tags = {
    Name = "${var.project_name}-S3-Destination-Location"
  }
}

resource "aws_datasync_task" "datasync_backup_task" {
  name                     = "${var.project_name}-efs-backup-task"
  source_location_arn      = aws_datasync_location_efs.datasync_source.arn
  destination_location_arn = aws_datasync_location_s3.datasync_destination.arn

  options {
    bytes_per_second       = -1
    preserve_deleted_files = "REMOVE"
    preserve_devices       = "NONE"
    posix_permissions      = "PRESERVE"
    uid                    = "INT_VALUE"
    gid                    = "INT_VALUE"
    mtime                  = "PRESERVE"
    atime                  = "BEST_EFFORT"
    verify_mode            = "ONLY_FILES_TRANSFERRED"
    overwrite_mode         = "ALWAYS"
    transfer_mode          = "CHANGED"
    task_queueing          = "ENABLED"
    log_level              = "TRANSFER"
  }

  excludes {
    filter_type = "SIMPLE_PATTERN"
    value       = "/upload/.tmp/*"
  }

  schedule {
    schedule_expression = var.backup_schedule
  }

  tags = {
    Name = "${var.project_name}-EFS-Backup-Task"
  }
}