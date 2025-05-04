variable "lambda_function_name" {
  type = string
}

variable "zip_file" {
  type = string
}

variable "handler" {
  type    = string
  default = "lambda_function.lambda_handler"
}

variable "runtime" {
  type    = string
  default = "python3.9"
}

variable "lambda_exec_role_arn" {
  type = string
}

variable "environment_variables" {
  type    = map(string)
  default = {}
}