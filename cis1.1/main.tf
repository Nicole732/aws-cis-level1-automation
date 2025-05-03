
module "sns" {
  source      = "../modules/sns_topic"
  topic_name  = "cis11-contact-check-topic"
  email       = var.alert_email
}

module "iam_role" {
  source     = "../modules/iam_lambda_role"
  role_name  = "cis11-contact-check-role"
}

module "lambda" {
  source                    = "../modules/lambda_function"
  lambda_function_name      = "cis1_1_contact_check" #module.lambda.lambda_function_name
  zip_file                  = "lambda_contact_check.zip"
  handler                   = "lambda_function.lambda_handler"
  lambda_exec_role_arn = module.iam_role.role_arn

  environment_variables     = {
    SNS_TOPIC_ARN = module.sns.topic_arn
  }
}

module "schedule" {
  source                = "../modules/cloudwatch_schedule"
  schedule_name         = "cis_contact_check_schedule"
  schedule_expression   = "rate(1 day)"
  lambda_function_arn   = module.lambda.this.arn
  lambda_function_name  = module.lambda.this.function_name
}