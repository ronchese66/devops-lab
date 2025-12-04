data "aws_caller_identity" "current" {}
data "aws_region" "current_region" {}

resource "aws_kms_key" "secrets_manager_key" {
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.sm_deletion_window_in_days

  tags = {
    Name      = "${var.project_name}-Secrets-Manager-Key"
    ManagedBy = "Terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "secrets_manager_key_alias" {
  name          = "alias/${var.project_name}-secrets-manager"
  target_key_id = aws_kms_key.secrets_manager_key.key_id
}

resource "aws_kms_key_policy" "secrets_manager_key_policy" {
  key_id = aws_kms_key.secrets_manager_key.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "secrets-manager-key-policy"
    Statement = [
      {
        Sid    = "Enable IAM User permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Secrets Manager use the key"
        Effect = "Allow"
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:CreateGrant"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${data.aws_region.current_region.name}.amazonaws.com"
          }
        }
      },
      {
        Sid    = "Allow Secrets Manager creates grants"
        Effect = "Allow"
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        }
        Action = [
          "kms:GenerateDataKey",
          "kms:GenerateDataKeyWithoutPlaintext",
          "kms:Encrypt",
          "kms:ReEncrypt*"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "secretsmanager.${data.aws_region.current_region.name}.amazonaws.com"
          }
        }

      }
    ]
  })
}