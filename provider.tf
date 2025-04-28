provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region

  default_tags {
    tags = {
      Environment = "Development"
      Owner       = "NicoleK"
      ManagedBy   = "Terraform"
      Project     = "Capstone Project Masters UMBC 2025"
    }
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}