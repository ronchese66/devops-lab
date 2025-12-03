output "db_password_secret_arn" {
  value = aws_secretsmanager_secret.db_password.arn
}

output "db_password_secret_name" {
  value = aws_secretsmanager_secret.db_password.name
}

output "db_password_value" {
  value = random_password.db_password_gen.result
  sensitive = true
}