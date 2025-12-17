resource "aws_cloudwatch_log_group" "rds_psql_logs" {
  name = "/aws/rds/cluster/${var.project_name}-cluster/postgresql"
  retention_in_days = var.rds_retention_in_days
  kms_key_id = var.cloudwatch_logs_key_arn

  tags = {
    Name = "${var.project_name}-RDS-PostgreSQL-Logs"
  }
}