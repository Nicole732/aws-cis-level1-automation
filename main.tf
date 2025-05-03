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
