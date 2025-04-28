#This page describes configurations for CIS AWS Foundations Benchmark level 1 controls"
# Identity and Access Management Coontrols #
#CIS 1.1: Maintain current contact details#

resource "aws_sns_topic" "current_contact_details" {
  name = "current_contact_details"
}

resource "aws_sns_topic_subscription" "current_contact_details_subscription" {
  topic_arn = aws_sns_topic.current_contact_details.arn
  protocol  = "email"
  endpoint  = var.contact_email
}


#resource "null_resource" "send_update_contact_details" {
# provisioner "local-exec" {
#   command = "aws sns publish --topic-arn ${aws_sns_topic.current_contact_details.arn} --subject \"Update Your AWS Contact Information\" --message \"Hi! Please ensure your AWS account contact details are up-to-date as per CIS AWS Foundations Benchmark 1.1.\""
#}
#  depends_on = [aws_sns_topic.current_contact_details]
#}


#Settings for AWS Config
# S3 Bucket for AWS Config Delivery Channel
resource "random_pet" "bucket_name" {
  length    = 2
  separator = "-"
}

resource "random_integer" "unique_id" {
  min = 100
  max = 999
}

resource "aws_s3_bucket" "config_bucket" {
  bucket = "my-config-bucket-${random_pet.bucket_name.id}-${random_integer.unique_id.result}" #generates a unique bucket name
  force_destroy = true  #for dev, to destroy bucket and objects
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
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })
}

# Attach managed policy for AWS Config
resource "aws_iam_role_policy_attachment" "config_role_attachment" {
  role = aws_iam_role.config_role.name
  #my account is part of an AWS organization 
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
  # sns_topic_arn  = aws_sns_topic.current_contact_details.arn #use different subscription
  depends_on     = [aws_config_configuration_recorder.main]
}

# Option: Use  AMAZON SNS topic to stream configuration changes

#CIS 1.3 control: Root user access key doesn't exist
resource "aws_config_config_rule" "root_access_key_check" {
  name = "iam-root-access-key-check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }

  depends_on = [
    aws_config_configuration_recorder.main,
    aws_config_delivery_channel.main
  ]
}

#CIS 1.4 Ensure MFA is enabled for the 'root' user account 
# AWS Managed rule
resource "aws_config_config_rule" "root_mfa_check" {
  name = "root-account-mfa-enabled"

  source {
    owner             = "AWS"
    source_identifier = "ROOT_ACCOUNT_MFA_ENABLED"
  }

  depends_on = [
    aws_config_configuration_recorder.main,
    aws_config_delivery_channel.main
  ]
}
