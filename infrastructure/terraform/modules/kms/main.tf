data "aws_caller_identity" "current" {}

resource "aws_kms_key" "eks_secrets" {
  description             = "KMS key for EKS Kubernetes secrets encryption"
  enable_key_rotation     = var.enable_key_rotation
  deletion_window_in_days = var.deletion_window_in_days

  tags = {
    Name      = "${var.project_name}-EKS-Secrets-Key"
    ManagedBy = "Terraform"
  }
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "eks_secrets" {
  name          = "alias/${var.project_name}-eks-secrets"
  target_key_id = aws_kms_key.eks_secrets.key_id
}

resource "aws_kms_key_policy" "eks_secrets_policy" {
  key_id = aws_kms_key.eks_secrets.id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "eks-secrets-key-policy"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Action = "kms:*"
        Resource = "*"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
      },
      {
        Sid    = "Allow EKS to use key"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}
