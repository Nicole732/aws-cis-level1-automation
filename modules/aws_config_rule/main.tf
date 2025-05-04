## CIS Controls with AWS COnfig Managed Rules ##

resource "aws_config_config_rule" "config_rule" {
  name        = var.rule_name
  description = var.description

  source {
    owner             = "AWS"
    source_identifier = var.source_identifier
  }

  #depends_on = var.config_depends_on
}