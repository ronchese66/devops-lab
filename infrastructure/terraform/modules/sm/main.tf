resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.project_name}-db-password"
  kms_key_id              = var.secrets_manager_key_arn
  recovery_window_in_days = var.recovery_window_in_days

  tags = {  
    Name = "${var.project_name}-DB-Password"
  }
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id = aws_secretsmanager_secret.db_password.id

  secret_string = random_password.db_password_gen.result
}

resource "random_password" "db_password_gen" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}:?"
}