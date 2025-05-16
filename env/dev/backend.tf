terraform {
  backend "s3" {
    bucket = "cis-aws-benchmark-backend"
    key    = "env/dev/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
  }
}