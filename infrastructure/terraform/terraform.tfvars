project_name            = "immich"
aws_region              = "us-east-1"
aws_profile             = "terraform"
enable_key_rotation     = true
sm_deletion_window_in_days = 30
cloudwatch_deletion_window_in_days = 7
efs_deletion_window_in_days = 30
backup_schedule = "cron(0 3 * * ? *)" # Minute/Hour/Day/Month/Weekday/Year