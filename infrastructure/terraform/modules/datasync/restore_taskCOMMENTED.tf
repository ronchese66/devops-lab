# WHEN TO USE
# Primary storage (EFS) is lost, corrupted or destroyed
# Need to restore all data from S3 backup bucket to a new EFS (create before)

resource "aws_datasync_location_efs" "restore_destination" {
  efs_file_system_arn = "NEW EFS ARN"

  ec2_config {
    security_group_arns = ["NEW EFS MOUNT TARGET SECURITY GROUP ARN"]
    subnet_arn          = var.private_subnet_arns[0]
  }

  tags = {
    Name = "${var.project_name}-EFS-Restore-Destination"
  }
}

resource "aws_datasync_task" "datasync_restore_task" {
  name                     = "${var.project_name}-efs-restore-task"
  source_location_arn      = aws_datasync_location_s3.datasync_destination.arn
  destination_location_arn = aws_datasync_location_efs.restore_destination.arn

  options {
    bytes_per_second       = -1
    preserve_deleted_files = "PRESERVE"
    preserve_devices       = "NONE"
    posix_permissions      = "PRESERVE"
    uid                    = "INT_VALUE"
    gid                    = "INT_VALUE"
    mtime                  = "PRESERVE"
    atime                  = "BEST_EFFORT"
    verify_mode            = "ONLY_FILES_TRANSFERRED"
    overwrite_mode         = "ALWAYS"
    transfer_mode          = "ALL"
    task_queueing          = "ENABLED"
    log_level              = "TRANSFER"
  }

  tags = {
    Name = "${var.project_name}-EFS-Restore-Task"
  }
}