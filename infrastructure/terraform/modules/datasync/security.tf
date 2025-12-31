data "aws_caller_identity" "current" {}
data "aws_region" "current_region" {}

resource "aws_iam_role" "datasync_role" {
  name = "${var.project_name}-datasync-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "datasync.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-DataSync-Role"
  }
}

resource "aws_iam_role_policy" "datasync_s3_access" {
  name = "${var.project_name}-datasync-s3-policy"
  role = aws_iam_role.datasync_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AccessToS3"
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads"
        ]
        Resource = aws_s3_bucket.backup_bucket.arn
      },
      {
        Sid    = "AccessToS3Objects"
        Effect = "Allow"
        Action = [
          "s3:AbortMultipartUpload",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:GetObjectTagging",
          "s3:PutObjectTagging"
        ]
        Resource = "${aws_s3_bucket.backup_bucket.arn}/*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "datasync_efs_access" {
  name = "${var.project_name}-datasync-efs-policy"
  role = aws_iam_role.datasync_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AccessToEFS"
        Effect = "Allow"
        Action = [
          "elasticfilesystem:ClientMount",
          "elasticfilesystem:ClientWrite",
          "elasticfilesystem:ClientRootAccess",
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets"
        ]
        Resource = var.efs_file_system_arn
      },
      {
        Sid    = "EFSNetworkAccess"
        Effect = "Allow"
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "datasync_cloudwatch_access" {
  name = "${var.project_name}-datasync-logs-policy"
  role = aws_iam_role.datasync_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowCloudWatchLogsWrite"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.datasync_logs.arn}:*"
      }
    ]
  })
}

resource "aws_security_group" "datasync_sg" {
  name = "${var.project_name}-datasync-sg"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-DataSync-SG"
  }
}

resource "aws_security_group_rule" "datasync_outbound_nfs" {
  security_group_id = aws_security_group.datasync_sg.id
  type = "egress"
  protocol = "tcp"
  cidr_blocks = [var.vpc_cidr]
  from_port = 2049
  to_port = 2049
}

resource "aws_security_group_rule" "datasync_outbound_https" {
  security_group_id = aws_security_group.datasync_sg.id
  type = "egress"
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  from_port = 443
  to_port = 443
}

