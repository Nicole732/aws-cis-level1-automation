resource "aws_cloudwatch_event_rule" "alert" {
  name          = var.rule_name
  description   = var.description
  event_pattern = var.event_pattern
}

resource "aws_cloudwatch_event_target" "send_to_sns" {
  rule      = aws_cloudwatch_event_rule.alert.name
  target_id = "TargetToSNS"
  arn       = var.sns_topic_arn
}