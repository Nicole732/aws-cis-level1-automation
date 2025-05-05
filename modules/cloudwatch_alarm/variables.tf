variable "create_log_group" {
  description = "Whether to create the CloudWatch log group"
  type        = bool
  default     = false
}

variable "log_group_name" {
  description = "CloudTrail log group name (exisssting or created)"
  type        = string
}

variable "filter_pattern" {
  description = "CloudWatch Logs filter pattern"
  type        = string
}

variable "metric_name" {
  description = "Name of the CloudWatch metric"
  type        = string
}

variable "metric_namespace" {
  description = "Namespace for the CloudWatch metric"
  type        = string
  default     = "CISMetrics"
}

variable "alarm_name" {
  description = "Name of the alarm"
  type        = string
}

variable "alarm_description" {
  description = "Description of the alarm"
  type        = string
}

variable "metric_filter_name" {
  description = "Name of the CloudWatch metric filter"
  type        = string
}

variable "topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name for CloudTrail log delivery"
}