output "secrets_manager_key_id" {
  value = aws_kms_key.secrets_manager_key.key_id
}

output "secrets_manager_key_arn" {
  value = aws_kms_key.secrets_manager_key.arn
}

output "secrets_manager_key_alias" {
  value = aws_kms_alias.secrets_manager_key_alias.name
}

output "cloudwatch_logs_key_id" {
  value = aws_kms_key.cloudwatch_logs_key.key_id
}

output "cloudwatch_logs_key_arn" {
  value = aws_kms_key.cloudwatch_logs_key.arn
}

output "cloudwatch_logs_key_alias" {
  value = aws_kms_alias.cloudwatch_logs_key_alias.name
}

output "efs_key_arn" {
  value = aws_kms_key.efs_key.arn
}