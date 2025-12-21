resource "aws_cloudwatch_log_group" "redis_engine_log" {
  name = "/aws/elasticache/redis/${var.project_name}/engine-log"
  retention_in_days = 7
  kms_key_id = var.cloudwatch_logs_key_arn

  tags = {
    Name = "${var.project_name}-Redis-Engine-Logs"
  }
}