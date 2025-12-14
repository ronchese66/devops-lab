resource "aws_sns_topic" "backup_notifications" {
  name = "${var.project_name}-datasync-backup-notifications"

  tags = {
    Name = "${var.project_name}-DataSync-Notifications"
  }
}

resource "aws_sns_topic_subscription" "backup_email" {
  topic_arn = aws_sns_topic.backup_notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

resource "aws_sns_topic_policy" "backup_notifications_policy" {
  arn = aws_sns_topic.backup_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Allow Event Bridge to publish"
        Effect = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.backup_notifications.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

resource "aws_cloudwatch_event_rule" "datasync_backup_started" {
  description = "trigger when datasync task exec starts"
  name        = "${var.project_name}-datasync-backup-started"

  event_pattern = jsonencode({
    source      = ["aws.datasync"]
    detail-type = ["DataSync Task exec state change"]
    detail = {
      State   = ["LAUNCHING"]
      TaskArn = [aws_datasync_task.datasync_backup_task.arn]
    }
  })

  tags = {
    Name = "${var.project_name}-DataSync-Backup-Started-Rule"
  }
}

resource "aws_cloudwatch_event_target" "datasync_backup_started_sns" {
  rule      = aws_cloudwatch_event_rule.datasync_backup_started.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.backup_notifications.arn

  input_transformer {
    input_paths = {
      taskArn      = "$.detail.TaskArn"
      state        = "$.detail.State"
      executionArn = "$.detail.TaskExecuitionArn"
    }
    input_template = "\"DataSync Backup started: Task <taskArn> execution <executionArn> is now in state <state>\""
  }
}

resource "aws_cloudwatch_event_rule" "datasync_backup_success" {
  description = "trigger when datasync task exec succeeds"
  name        = "${var.project_name}-datasync-backup-success"

  event_pattern = jsonencode({
    source      = ["aws.datasync"]
    detail-type = ["DataSync Task exec state changed"]
    detail = {
      State   = ["SUCCESS"]
      TaskArn = [aws_datasync_task.datasync_backup_task.arn]
    }
  })

  tags = {
    Name = "${var.project_name}-DataSync-Backup-Success-Rule"
  }
}

resource "aws_cloudwatch_event_target" "datasync_backup_success_sns" {
  rule      = aws_cloudwatch_event_rule.datasync_backup_success.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.backup_notifications.arn

  input_transformer {
    input_paths = {
      taskArn          = "$.detail.TaskArn"
      executionArn     = "$.detail.TaskExecutionArn"
      filesTransferred = "$.detail.FilesTransferred"
      bytesTransferred = "$.detail.BytesTransferred"
    }
    input_template = "\"DataSync Backup completed successfully: Transferred <filesTransferred> files (<bytesTransferred> bytes). Execution: <executionArn>\""
  }
}

resource "aws_cloudwatch_event_rule" "datasync_backup_failed" {
  description = "trigger when datasync task exec fails"
  name        = "${var.project_name}-datasync-backup-failed"

  event_pattern = jsonencode({
    source      = ["aws.datasync"]
    detail-type = ["DataSync Task exec state changed"]
    detail = {
      State   = ["ERROR"]
      TaskArn = [aws_datasync_task.datasync_backup_task.arn]
    }
  })

  tags = {
    Name = "${var.project_name}-DataSync-Backup-Failed-Rule"
  }
}

resource "aws_cloudwatch_event_target" "datasync_backup_failed_sns" {
  rule      = aws_cloudwatch_event_rule.datasync_backup_failed.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.backup_notifications.arn

  input_transformer {
    input_paths = {
      taskArn      = "$.detail.TaskArn"
      executionArn = "$.detail.TaskExecutionArn"
      errorCode    = "$.detail.ErrorCode"
      errorDetail  = "$.detail.ErrorDetail"
    }
    input_template = "\"ALERT: DataSync Backup FAILED! Task: <taskArn>, Execution: <executionArn>, Error: <errorCode> - <errorDetail>\""
  }
}