data "aws_caller_identity" "current" {}

resource "aws_flow_log" "vpc_flow_logs" {
  depends_on           = [aws_iam_role_policy.flow_logs_to_s3]
  vpc_id               = aws_vpc.vpc.id
  traffic_type         = "ALL"
  log_destination      = aws_s3_bucket.flow_logs.arn
  log_destination_type = "s3"
  log_format           = var.flow_log_format

  tags = {
    Name = "${var.project_name}-VPC-Flow-Log"
  }
}

resource "aws_s3_bucket" "flow_logs" {
  bucket = "${var.project_name}-vpc-flow-logs-${data.aws_caller_identity.current.account_id}"

  tags = {
    Name = "${var.project_name}-VPC-Flow-Logs"
  }
}

resource "aws_s3_bucket_public_access_block" "flow_logs_public_access" {
  bucket = aws_s3_bucket.flow_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "flow_logs_lifecycle" {
  bucket = aws_s3_bucket.flow_logs.id

  rule {
    id     = "optimize-storage"
    status = "Enabled"
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs_encryption" {
  bucket = aws_s3_bucket.flow_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_iam_role" "flow_logs_role" {
  name = "${var.project_name}-vpc-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "flow_logs_to_s3" {
  name = "${var.project_name}-flow-logs-s3-write"
  role = aws_iam_role.flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.flow_logs.arn,
          "${aws_s3_bucket.flow_logs.arn}/*"
        ]
      }
    ]
  })
}