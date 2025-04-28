#provider configuration
output "aws_region_output" {
  description = "The AWS region being used"
  value       = var.aws_region
}
#iam 1.1
output "sns_topic_arn" {
  description = "ARN of the current Contact Info Notification SNS Topic"
  value       = aws_sns_topic.current_contact_details.arn
}
