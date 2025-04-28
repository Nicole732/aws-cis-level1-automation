#This page describes configurations for CIS AWS Foundations Benchmark level 1 controls"
# Identity and Access Management Coontrols #
#IAM 1.1: Maintain current contact details#

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

