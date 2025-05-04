resource "aws_cloudwatch_log_group" "optional_log_group" {
  count = var.create_log_group ? 1 : 0
  name  = var.log_group_name
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
    aws_cloudwatch_log_group.optional_log_group
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
