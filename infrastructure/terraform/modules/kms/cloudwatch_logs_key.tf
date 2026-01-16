resource "aws_kms_key" "cloudwatch_logs_key" {
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.cloudwatch_deletion_window_in_days

  tags = {
    Name      = "${var.project_name}-CloudWatch-Logs-Key"
    ManagedBy = "Terraform"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_kms_alias" "cloudwatch_logs_key_alias" {
  name          = "alias/${var.project_name}-cloudwatch-logs"
  target_key_id = aws_kms_key.cloudwatch_logs_key.key_id
}

resource "aws_kms_key_policy" "cloudwatch_logs_key_policy" {
  key_id = aws_kms_key.cloudwatch_logs_key.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "cloudwatch-logs-key-policy"
    Statement = [
      {
        Sid    = "EnableIAMUserPermissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogsUseTheKey"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current_region.name}:${data.aws_caller_identity.current.account_id}:log-group:*"
          }
        }
      },
      {
        Sid    = "AllowSSMUseTheKey"
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "ssm.${data.aws_region.current_region.name}.amazonaws.com"
          }
        }
      },
      {
        Sid = "AllowDataSyncService"
        Effect = "Allow"
        Principal = {
          Service = "datasync.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      },
      {
        Sid = "AllowDataSyncRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.project_name}-datasync-role"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}