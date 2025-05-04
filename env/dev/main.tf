#This page describes configurations for CIS AWS Foundations Benchmark level 1 controls"

# Identity and Access Management Coontrols #
#CIS 1.1: Maintain current contact details#

#used to set uup   unique resourrces names
resource "random_pet" "bucket_name" {
  length    = 2
  separator = "-"
}

resource "random_integer" "unique_id" {
  min = 100
  max = 999
}

### CIS 1-1 ###
#CIS 1.1: Maintain current contact details#
#Continuously checks if control is in place and alerts for manual remediation
#Lambda + CloudWatch EnventBridge (cron) + SNS

module "sns" {
  source     = "../../modules/sns_topic"
  topic_name = "cis11-contact-check-topic"
  email      = var.alert_email
}

module "iam_role" {
  source    = "../../modules/iam_lambda_role"
  role_name = "cis1_1-contact-check-role"
  topic_arn = module.sns.topic_arn
}

#create zip file of lambda_function and save in same directory
#deploy and  test  lambda
module "lambda" {
  source               = "../../modules/lambda_function"
  lambda_function_name = "cis1_1_contact_check" #module.lambda.lambda_function_name
  zip_file             = "lambda_function.zip"
  handler              = "lambda_function.lambda_handler"
  lambda_exec_role_arn = module.iam_role.role_arn

  environment_variables = {
    SNS_TOPIC_ARN = module.sns.topic_arn
  }
}

module "schedule" {
  source        = "../../modules/cloudwatch_schedule"
  schedule_name = "cis1_1_contact_check_schedule"
  #"rate(1 day)" #"rate(5 minutes) for testing
  schedule_expression  = "rate(5 minutes)"
  lambda_function_arn  = module.lambda.lambda_function_arn
  lambda_function_name = module.lambda.lambda_function_name
}

### CIS 1.3: Ensure no 'root' user account access key exists
# AWS Config continuously monitor control and returns Compliant/Non Compliant Status
# AWS Config managed rule: iam-root-acces-key-check


module "cis_1_3_root_key_check" {
  source            = "../modules/aws_config_rule"
  rule_name         = "cis-1-3-root-access-key-check"
  topic_name        = "cis13-croot-access-key-alerts"
  description       = "CIS 1.3: Ensure no root user account access key exists"
  source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
}

module "cis_1_4_root_mfa_check" {
  source            = "../modules/aws_config_rule"
  rule_name         = "cis-1-4-root-mfa-check"
  topic_name        = "cis14-root-mfa-alerts"
  description       = "CIS 1.4: Ensure MFA is enabled for the root user"
  source_identifier = "ROOT_ACCOUNT_MFA_ENABLED" #root-account-mfa-enabled

}
