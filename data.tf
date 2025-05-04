#fetches account id
data "aws_caller_identity" "current" {}

#fetches aws config role
data "aws_iam_role" "aws_config" {
  name = "aws-config-role"
}