variable "role_name" {
  default     = "cis-contact-check-lambda-role"
  description = "Name of the Lambda execution role"
  type        = string
}

variable "topic_arn" {
  description = "ARN of the SNS topic to allow publishing to"
  type        = string
}

