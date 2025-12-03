resource "aws_cloudwatch_log_group" "app_log_group" {
  name = "/ecs/${var.project_name}/app"
  retention_in_days = var.retention_in_days
  kms_key_id = var.cloudwatch_logs_key_arn

  tags = {
    Name = "${var.project_name}-App-Logs"
  }
}

resource "aws_cloudwatch_log_group" "ml_log_group" {
  name = "/ecs/${var.project_name}/ml"
  retention_in_days = var.retention_in_days
  kms_key_id = var.cloudwatch_logs_key_arn

  tags = {
    Name = "${var.project_name}-ML-Logs"
  }
}

resource "aws_cloudwatch_log_group" "ecs_exec_log_group" {
  name = "/ecs/${var.project_name}/exec"
  retention_in_days = var.exec_logs_retention_in_days
  kms_key_id = var.cloudwatch_logs_key_arn

  tags = {
    Name = "${var.project_name}-ECS-Exec-Logs"
  }
}

