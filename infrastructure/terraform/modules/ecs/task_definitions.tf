data "aws_region" "current" {}

resource "aws_ecs_task_definition" "app" {
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_task_app.arn

  family                   = "${var.project_name}-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "2048"
  memory = "4096"

  volume {
    name = "immich-uploads"

    efs_volume_configuration {
      file_system_id          = var.efs_file_system_id
      root_directory          = "/"
      transit_encryption      = "ENABLED"
      transit_encryption_port = 2049

      authorization_config {
        access_point_id = var.efs_access_point_id
        iam             = "ENABLED"
      }
    }
  }

  container_definitions = jsonencode([
    {
      name      = "immich-app"
      image     = "ghcr.io/immich-app/immich-server:${var.immich_version}"
      essential = true

      mountPoints = [
        {
          sourceVolume  = "immich-uploads"
          containerPath = "/usr/src/app/upload"
          readOnly      = false
        }
      ]

      portMappings = [
        {
          containerPort = 2283
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "DB_HOSTNAME", value = "database.${var.project_name}.internal" },
        { name = "DB_USERNAME", value = "postgres" },
        { name = "DB_DATABASE_NAME", value = "immich" },
        { name = "REDIS_HOSTNAME", value = "redis.${var.project_name}.internal" },
        { name = "UPLOAD_LOCATION", value = "/usr/src/app/upload" },
        { name = "IMMICH_MACHINE_LEARNING_URL", value = "http://ml.${var.project_name}.local:3003" },
        { name = "TZ", value = "Europe/Kyiv" }
      ]

      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = var.db_password_secret_arn
        }
      ]

      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://localhost:2283/server/ping || exit 1"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.app_log_group.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-App-TD"
  }
}

resource "aws_ecs_task_definition" "ml" {
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  task_role_arn      = aws_iam_role.ecs_task_ml.arn

  family                   = "${var.project_name}-ml"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = "1024"
  memory = "4096"

  container_definitions = jsonencode([
    {
      name      = "immich-ml"
      image     = "ghcr.io/immich-app/immich-machine-learning:${var.immich_version}"
      essential = true

      portMappings = [
        {
          containerPort = 3003
          protocol      = "tcp"
        }
      ]

      environment = [
        { name = "TZ", value = "Europe/Kyiv" }
      ]

      healthCheck = {
        command = [
          "CMD-SHELL",
          "timeout 5 bash -c '</dev/tcp/localhost/3003' || exit 1"
        ]
        interval    = 30
        timeout     = 10
        retries     = 3
        startPeriod = 120
      }

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ml_log_group.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-ML-TD"
  }
}
