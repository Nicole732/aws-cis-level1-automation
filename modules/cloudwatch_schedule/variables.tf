variable "schedule_name" {
  type = string
}

variable "schedule_expression" {
  type    = string
  default = "rate(1 day)"
}

variable "description" {
  type    = string
  default = ""
}

variable "lambda_function_arn" {
  type = string
}

variable "lambda_function_name" {
  type = string
}