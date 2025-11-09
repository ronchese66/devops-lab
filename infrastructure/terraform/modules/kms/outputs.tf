output "kms_key_arn" {
  description = "ARN of the KMS key used for EKS encryption"
  value = aws_kms_key.eks_secrets.arn
}