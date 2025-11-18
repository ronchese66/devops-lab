resource "aws_cloudwatch_log_group" "eks_logs" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 5
  kms_key_id        = var.kms_key_arn

  tags = {
    Name      = "${var.cluster_name}-EKS-Cluster-Logs"
    ManagedBy = "Terraform"
  }

  lifecycle {
    prevent_destroy = true
  }
}