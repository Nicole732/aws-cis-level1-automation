#This page describes configurations for CIS AWS Foundations Benchmark level 1 controls"

# Identity and Access Management Coontrols #
#CIS 1.1: Maintain current contact details#
module "sns" {
  source      = "../../modules/sns_topic"
  topic_name  = "cis-contact-check-topic"
  email       = var.alert_email
}

module "iam_role" {
  source     = "../../modules/iam_lambda_role"
  role_name  = "cis-contact-check-role"
}

module "lambda" {
  source                    = "../../modules/lambda_function"
  function_name             = "cis_contact_check"
  zip_file                  = "lambda_contact_check.zip"
  handler                   = "lambda_function.lambda_handler"
  lambda_execution_role_arn = module.iam_role.role_arn
  environment_variables     = {
    SNS_TOPIC_ARN = module.sns.topic_arn
  }
}

module "schedule" {
  source                = "../../modules/cloudwatch_schedule"
  schedule_name         = "cis_contact_check_schedule"
  schedule_expression   = "rate(1 day)"
  lambda_function_arn   = module.lambda.this.arn
  lambda_function_name  = module.lambda.this.function_name
}
