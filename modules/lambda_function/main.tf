resource "aws_lambda_function" "this" {
  function_name    = var.lambda_function_name
  filename         = var.zip_file
  role             = var.lambda_exec_role_arn
  handler          = var.handler
  runtime          = var.runtime
  source_code_hash = filebase64sha256(var.zip_file)

  environment {
    variables = var.environment_variables
  }

}