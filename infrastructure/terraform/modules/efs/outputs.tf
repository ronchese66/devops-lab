output "efs_mount_target_sg_id" {
  value = aws_security_group.mount_targets.id
}

output "efs_mount_target_sg_arn" {
  value = aws_security_group.mount_targets.arn
}

output "efs_file_system_id" {
  value = aws_efs_file_system.immich_storage.id
}

output "efs_file_system_arn" {
  value = aws_efs_file_system.immich_storage.arn
}

output "efs_access_point_id" {
  value = aws_efs_access_point.immich_uploads.id
}

output "efs_access_point_arn" {
  value = aws_efs_access_point.immich_uploads.arn
}

output "efs_mount_targets_ready" {
  value = [for mt in aws_efs_mount_target.immich_storage_mt : mt.id]
}