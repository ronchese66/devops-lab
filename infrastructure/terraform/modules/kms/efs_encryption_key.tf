resource "aws_kms_key" "efs_key" {
  deletion_window_in_days = var.efs_deletion_window_in_days
  enable_key_rotation     = true

  tags = {
    Name = "${var.project_name}-EFS-Encrytion-Key"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "efs_key_alias" {
  name          = "alias/${var.project_name}-efs-encryption-key"
  target_key_id = aws_kms_key.efs_key.key_id
}

resource "aws_kms_key_policy" "efs_key_policy" {
  key_id = aws_kms_key.efs_key.id

  policy = jsonencode({
    Version = "2012-10-17"
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
        Sid    = "AllowEFSToUseKey"
        Effect = "Allow"
        Principal = {
          Service = "elasticfilesystem.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "kms:ViaService" = "elasticfilesystem.${data.aws_region.current_region.name}.amazonaws.com"
          }
        }
      }
    ]
  })
}