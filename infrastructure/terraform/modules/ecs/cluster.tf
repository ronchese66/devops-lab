resource "aws_ecs_cluster" "immich_cluster" {
  name = "${var.project_name}-cluster"

  setting {
    name = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.ecs_exec_log_group.name
      }
    }
  }

  tags = {
    Name = "${var.project_name}-ECS-Cluster"
  }
}