#This page describes configurations for CIS AWS Foundations Benchmark level 1 controls"
# Identity and Access Management Coontrols #
#CIS 1.1: Maintain current contact details#

data "aws_caller_identity" "current" {}

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
  topic_name = "cis11-conctact-email-alerts"
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
  description   = "CIS 1.1 Alert to maintain a current contact details"
  #"rate(1 day)" for prod #"rate(5 minutes) for testing
  schedule_expression  = "rate(5 minutes)"
  lambda_function_arn  = module.lambda.lambda_function_arn
  lambda_function_name = module.lambda.lambda_function_name
}

## CIS AWS COnfig Managed Rules ####

resource "aws_s3_bucket" "config_bucket" {
  bucket        = "my-config-bucket-${random_pet.bucket_name.id}-${random_integer.unique_id.result}" #generates a unique bucket name
  force_destroy = true                                                                               #for dev, to destroy bucket and objects
}

#attach a bucket policy that allows AWS Config to put objects in s3 bucket
resource "aws_s3_bucket_policy" "config_bucket_policy" {
  bucket = aws_s3_bucket.config_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action = [
          "s3:GetBucketAcl",
          "s3:PutObject"
        ],
        Resource = [
          "${aws_s3_bucket.config_bucket.arn}",
          "${aws_s3_bucket.config_bucket.arn}/*"
        ],
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# IAM Role for AWS Config
resource "aws_iam_role" "config_role" {
  name = "aws-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {

        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action = "sts:AssumeRole"

      }
    ]
  })
}

# Attach managed policy for AWS Config
resource "aws_iam_role_policy_attachment" "config_role_attachment" {
  role = aws_iam_role.config_role.name
  #this account is part of an AWS organization 
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
  #policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole #if account  not part of an organization
}

# AWS Config Recorder
resource "aws_config_configuration_recorder" "main" {
  name     = "default"
  role_arn = aws_iam_role.config_role.arn

}

# AWS Config Delivery Channel
resource "aws_config_delivery_channel" "main" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
  #add sns notification when rule in non compliant mode
  #sns_topic_arn  = module.sns.topic.arn 
  depends_on = [aws_config_configuration_recorder.main]
}

resource "aws_config_configuration_recorder_status" "default" {
  name       = aws_config_configuration_recorder.main.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.main]
}

### CIS 1.3: Ensure no 'root' user account access key exists
# AWS Config continuously monitor control and returns Compliant/Non Compliant Status
# AWS Config managed rule: iam-root-acces-key-check


module "cis_1_3_root_key_check" {
  source            = "../../modules/aws_config_rule"
  rule_name         = "cis-1-3-root-access-key-check"
  description       = "CIS 1.3: Ensure no root user account access key exists"
  source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"

  depends_on = [
    aws_config_configuration_recorder_status.default,
    aws_config_delivery_channel.main
  ]
}

#CIS 1.4 Ensure MFA is enabled for the 'root' user account

module "cis_1_4_root_mfa_check" {
  source            = "../../modules/aws_config_rule"
  rule_name         = "cis-1-4-root-mfa-check"
  description       = "CIS 1.4: Ensure MFA is enabled for the root user"
  source_identifier = "ROOT_ACCOUNT_MFA_ENABLED" #root-account-mfa-enabled

  depends_on = [
    aws_config_configuration_recorder_status.default,
    aws_config_delivery_channel.main
  ]

}

#CIS 1.7 Ensure IAM password policy requires minimum length of 14 or greater 

module "cis_1_7_iam_password_policy" {
  source            = "../../modules/aws_config_rule"
  rule_name         = "cis-1-7-check-iam-policy"
  description       = "CIS 1.7: Ensure IAM password policy requires minimum length of 14 or greater"
  source_identifier = "IAM_PASSWORD_POLICY"

  depends_on = [
    aws_config_configuration_recorder_status.default,
    aws_config_delivery_channel.main
  ]
}

#CIS 1.9 Ensure multi-factor authentication (MFA) is enabled for all IAM users that have a console password 
module "cis_1_9_mfa_iam_console_users" {
  source            = "../../modules/aws_config_rule"
  rule_name         = "cis-1-9-console-mfa-check"
  description       = "CIS 1.9: Ensure MFA is enabled for console users"
  source_identifier = "MFA_ENABLED_FOR_IAM_CONSOLE_ACCESS"

  depends_on = [
    aws_config_configuration_recorder_status.default,
    aws_config_delivery_channel.main
  ]
}

### Event driven controls: CloudWatch(Event Bridge) + CloudTrail + SNS  
#### CIS 1.6: Detects Root Account Usage ###
module "sns_eventbridge_alert" {
  source     = "../../modules/sns_topic"
  topic_name = "cis-eventbridge-alerts"
  email      = var.alert_email
}


module "cis_1_6_root_user" {
  source        = "../../modules/cloudwatch_eventbridge"
  rule_name     = "cis-1-6-root-activity"
  description   = "CIS 1.6: Alert on any use of root account"
  sns_topic_arn = module.sns_eventbridge_alert.topic_arn

  event_pattern = jsonencode({
    source = ["aws.signin", "aws.console", "aws.cloudtrail"]
    "detail-type" = [
      "AWS Console Sign In via CloudTrail",
      "AWS API Call via CloudTrail"
    ]
    detail = {
      userIdentity = {
        type = ["Root"]
      }
    }
  })
}

#### CIS 1.10	Detectand alerts on IAM user creation with access key setup ###
module "cis_1_10_initial_access_key" {
  source        = "../../modules/cloudwatch_eventbridge"
  rule_name     = "cis-1-10-access-key-at-user-creation"
  description   = "CIS 1.10: Alert on creation of IAM user with access key"
  sns_topic_arn = module.sns_eventbridge_alert.topic_arn

  event_pattern = jsonencode({
    source        = ["aws.iam"],
    "detail-type" = ["AWS API Call via CloudTrail"],
    detail = {
      eventName = ["CreateUser", "CreateAccessKey", "CreateLoginProfile"]
      responseElements = {
        accessKey = {
          accessKeyId = [{
            exists = true
          }]
        }
      }
    }
  })
}

## Detect and  alert controls with CloudWatch (Alarms)  + SNS
module "sns_cloudwatch_alarms" {
  source     = "../../modules/sns_topic"
  topic_name = "cis-cloudwatch-alarms"
  email      = var.alert_email
}

resource "aws_s3_bucket" "trail_bucket" {
  bucket        = "cis-cloudtrail-bucket-${random_pet.bucket_name.id}-${random_integer.unique_id.result}"
  force_destroy = true
}

## CIS: 4.3 Ensure usage of the 'root' account is monitored 
module "cis_4_3_root_usage" {
  source             = "../../modules/cloudwatch_alarm"
  create_log_group   = false
  log_group_name     = "/aws/cloudtrail/logs/"
  s3_bucket_name     = aws_s3_bucket.trail_bucket.bucket
  filter_pattern     = <<EOF
{ ($.userIdentity.type = "Root") && ($.eventType != "AwsServiceEvent") }
  EOF
  metric_name        = "RootAccountUsageMetric"
  metric_filter_name = "CIS-4-3-Root-Usage"
  alarm_name         = "CIS-4.3-RootAccountUsageAlarm"
  alarm_description  = "Triggers on usage of the AWS root account"
  topic_arn          = module.sns_cloudwatch_alarms.topic_arn
}


## CIS 4.8: Ensure S3 bucket policy changes are monitored 
module "cis_4_8_s3_policy_change" {
  source           = "../../modules/cloudwatch_alarm"
  create_log_group = false
  log_group_name   = "/aws/cloudtrail/logs/"
  s3_bucket_name   = aws_s3_bucket.trail_bucket.bucket
  #filter_pattern        = "{ ($.eventName = \\"PutBucketPolicy\\") || ($.eventName = \\"DeleteBucketPolicy\\") || ($.eventName = \\"PutBucketAcl\\") || ($.eventName = \\"PutBucketCors\\") || ($.eventName = \\"PutBucketLogging\\") || ($.eventName = \\"PutBucketReplication\\") || ($.eventName = \\"PutBucketLifecycle\\") || ($.eventName = \\"PutBucketVersioning\\") }"
  filter_pattern     = <<EOF
{ ($.eventName = "PutBucketPolicy") ||
  ($.eventName = "DeleteBucketPolicy") ||
  ($.eventName = "PutBucketAcl") ||
  ($.eventName = "PutBucketCors") ||
  ($.eventName = "PutBucketLogging") ||
  ($.eventName = "PutBucketReplication") ||
  ($.eventName = "PutBucketLifecycle") ||
  ($.eventName = "PutBucketVersioning") }
EOF
  metric_name        = "S3PolicyChangeMetric"
  metric_filter_name = "CIS-4-8-S3-Policy-Change"
  alarm_name         = "CIS-4.8-S3PolicyChangeAlarm"
  alarm_description  = "Triggers on changes to S3 bucket policies or permissions"
  topic_arn          = module.sns_cloudwatch_alarms.topic_arn
}