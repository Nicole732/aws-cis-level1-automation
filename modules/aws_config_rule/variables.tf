variable "rule_name" {
  description = "The name of the AWS Config rule"
  type        = string
}

variable "description" {
  description = "Description of the rule"
  type        = string
}

variable "source_identifier" {
  description = "AWS Config managed rule identifier"
  type        = string
}

#variable "topic_name" {
#  type = string
#}
#variable "config_depends_on" {
#  type        = any
#  description = "List of resources that must exist before config rule"
#  default     = []
#}
