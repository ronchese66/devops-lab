resource "aws_efs_file_system" "immich_storage" {
  kms_key_id = var.efs_key_arn
  encrypted = true
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"

  lifecycle_policy {
    transition_to_ia = "AFTER_90_DAYS"
  }

  lifecycle_policy {
    transition_to_primary_storage_class = "AFTER_1_ACCESS"
  }

  tags = {
    Name = "${var.project_name}-EFS-Storage"
  }
}

resource "aws_efs_mount_target" "immich_storage_mt" {
  for_each = var.private_subnet_ids

  file_system_id = aws_efs_file_system.immich_storage.id
  subnet_id = each.value
  security_groups = [aws_security_group.mount_targets.id]
}

resource "aws_efs_access_point" "immich_uploads" {
  file_system_id = aws_efs_file_system.immich_storage.id

  root_directory {
    path = "/upload"

    creation_info {
      owner_gid = 1000
      owner_uid = 1000
      permissions = "0755"
    }
  }

  posix_user {
    uid = 1000
    gid = 1000
  }

  tags = {
    Name = "${var.project_name}-EFS-Access-Point"
  }
}