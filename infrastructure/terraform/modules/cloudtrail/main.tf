resource "aws_cloudtrail" "cloudtrail" {
  name                          = "${var.project_name}-cloudtrail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_bucket.id
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true
  enable_logging                = true

  event_selector {
    include_management_events = true
    read_write_type           = "All"
  }

  depends_on = [
    aws_s3_bucket_policy.cloudtrail_s3_bucket_policy
  ]

  tags = {
    Name      = "${var.project_name}-CloudTrail"
    ManagedBy = "terraform"
  }
}