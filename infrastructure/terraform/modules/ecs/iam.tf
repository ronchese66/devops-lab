resource "aws_iam_role" "ecs_task_execution" {
  name = "${var.project_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = {
                Service = "ecs-tasks.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
    ]
  })

  tags = {
    Name = "${var.project_name}-ECS-Task-Execution-Role"
  }
}

resource "aws_iam_role_policy" "ecs_task_execution_secrets" {
  name = "${var.project_name}-ecs-execution-secrets-policy"
  role = aws_iam_role.ecs_task_execution.id 

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = [
                "secretsmanager:GetSecretValue"
            ]
            Resource = [
                var.db_password_secret_arn
            ]
        },
        {
            Effect = "Allow"
            Action = [
                "kms:Decrypt"
            ]
            Resource = var.secrets_manager_key_arn
        }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_secrets_attach" {
  role = aws_iam_role.ecs_task_execution.name 
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_app" {
  name = "${var.project_name}-ecs-task-app-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = {
                Service = "ecs-tasks.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
    ]
  })

  tags = {
    Name = "${var.project_name}-ECS-Task-App-Role"
  }
}

resource "aws_iam_role_policy" "ecs_task_app_efs" {
  name = "${var.project_name}-ecs-task-app-efs-policy"
  role = aws_iam_role.ecs_task_app.id 

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess"
        ]
        Resource = "LATER (efs arn)"
        Condition = {
          StringEquals = {
            "elasticfilesystem:AccessPointArn" = "LATER (efs access point arn)"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_app_exec" {
  name = "${var.project_name}-ecs-task-app-exec-policy"
  role = aws_iam_role.ecs_task_app.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ]
            Resource = "*"
        }
    ]
  })
}

resource "aws_iam_role" "ecs_task_ml" {
  name = "${var.project_name}-ecs-task-ml-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Principal = {
                Service = "ecs-tasks.amazonaws.com"
            }
            Action = "sts:AssumeRole"
        }
    ]
  })

  tags = {
    Name = "${var.project_name}-ECS-Task-ML-Role"
  }
}

resource "aws_iam_role_policy" "ecs_task_ml_exec" {
  name = "${var.project_name}-ecs-task-ml-exec-policy"
  role = aws_iam_role.ecs_task_ml.id 

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Effect = "Allow"
            Action = [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ]
            Resource = "*"
        }
    ]
  })
}