resource "aws_service_discovery_private_dns_namespace" "main" {
  name = "${var.project_name}.local"
  vpc  = var.vpc_id

  tags = {
    Name = "${var.project_name}-Service-Discovery"
  }
}

resource "aws_service_discovery_service" "ml" {
  name = "ml"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_config {
    failure_threshold = 1
  }

  tags = {
    Name = "${var.project_name}-ML-Service-Discovery"
  }
}

resource "aws_ecs_service" "app_service" {
  name             = "${var.project_name}-app"
  cluster          = aws_ecs_cluster.immich_cluster.id
  task_definition  = aws_ecs_task_definition.app.arn
  desired_count    = var.app_desired_count
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_app_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.app_target_group_arn
    container_name   = "immich-app"
    container_port   = 2283
  }
  enable_execute_command = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  propagate_tags = "SERVICE"

  depends_on = [aws_iam_role_policy.ecs_task_app_efs]

  tags = {
    Name = "${var.project_name}-App-Service"
  }
}

resource "aws_ecs_service" "ml" {
  name             = "${var.project_name}-ml"
  cluster          = aws_ecs_cluster.immich_cluster.id
  task_definition  = aws_ecs_task_definition.ml.arn
  desired_count    = var.ml_desired_count
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_ml_sg.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.ml.arn
  }
  enable_execute_command = true

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  propagate_tags = "SERVICE"

  tags = {
    Name = "${var.project_name}-ML-Service"
  }
}

