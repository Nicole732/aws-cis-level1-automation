variable "rule_name" {
  description = "Name of the EventBridge rule"
  type        = string
}

variable "description" {
  description = "Description for the rule"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic to notify"
  type        = string
}

variable "event_pattern" {
  description = "JSON EventBridge event pattern"
  type        = string
}