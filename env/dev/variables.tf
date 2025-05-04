#provider configurations
variable "aws_access_key" {
  description = "AWS Access Key ID"
  type        = string
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS Region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

#CIS 1.1
variable "alert_email" {
  description = "The email address to notify about maintaining AWS contact details"
  type        = string
}

#CIS 1.3
#variable "config_role_arn" {
#  description = "The ARN of the IAM role used by AWS Config"
#  type        = string
#}
