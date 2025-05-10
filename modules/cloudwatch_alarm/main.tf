resource "aws_cloudwatch_log_group" "cloudtrail_log_group" {
  count = var.create_log_group ? 1 : 0
  name  = var.log_group_name
}

resource "aws_iam_role" "cloudtrail_logs_role" {
  count = var.create_log_group ? 1 : 0
  name  = "cloudtrail-to-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "cloudtrail.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "cloudtrail_logs_policy" {
  count = var.create_log_group ? 1 : 0
  name  = "cloudtrail-cloudwatch-policy"
  role  = aws_iam_role.cloudtrail_logs_role[0].name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      Resource = "${aws_cloudwatch_log_group.cloudtrail_log_group[0].arn}:*"
    }]
  })
}

resource "aws_cloudtrail" "cis_trail" {
  count                         = var.create_log_group ? 1 : 0
  name                          = "cis-compliance-trail"
  s3_bucket_name                = var.s3_bucket_name
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  cloud_watch_logs_group_arn    = aws_cloudwatch_log_group.cloudtrail_log_group[0].arn
  cloud_watch_logs_role_arn     = aws_iam_role.cloudtrail_logs_role[0].arn

  depends_on = [aws_iam_role_policy.cloudtrail_logs_policy]
}


resource "aws_cloudwatch_log_metric_filter" "cis_filter" {
  name           = var.metric_filter_name
  log_group_name = var.log_group_name
  pattern        = var.filter_pattern

  metric_transformation {
    name      = var.metric_name
    namespace = var.metric_namespace
    value     = "1"
  }

  depends_on = [
    aws_cloudwatch_log_group.cloudtrail_log_group
  ]
}

resource "aws_cloudwatch_metric_alarm" "cis_alarm" {
  alarm_name          = var.alarm_name
  alarm_description   = var.alarm_description
  metric_name         = var.metric_name
  namespace           = var.metric_namespace
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [var.topic_arn]
}
