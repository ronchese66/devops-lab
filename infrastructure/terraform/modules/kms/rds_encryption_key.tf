resource "aws_kms_key" "rds_key" {
  deletion_window_in_days = var.rds_deletion_window_in_days
  enable_key_rotation = true 

  tags = {
    Name = "${var.project_name}-RDS-Encryption-Key"
  }

  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_kms_alias" "rds_key_alias" {
  name = "alias/${var.project_name}-rds-encryption-key"
  target_key_id = aws_kms_key.rds_key.key_id
}

resource "aws_kms_key_policy" "rds_key_policy" {
  key_id = aws_kms_key.rds_key.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
        {
            Sid = "EnableIAMUserPermissions"
            Effect = "Allow"
            Principal = {
                AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            }
            Action = "kms:*"
            Resource = "*"
        },
        {
            Sid = "AllowRDSToUseKey"
            Effect = "Allow"
            Principal = {
                Service = "rds.amazonaws.com"
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
                    "kms:ViaService" = "rds.${data.aws_region.current_region.name}.amazonaws.com"
                }
            }
        }
    ]
  })
}