resource "aws_cloudwatch_event_rule" "this" {
  name                = var.schedule_name
  schedule_expression = var.schedule_expression
  description         = var.description
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule      = aws_cloudwatch_event_rule.this.name
  target_id = "target"
  arn       = var.lambda_function_arn
}

resource "aws_lambda_permission" "allow_schedule" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}