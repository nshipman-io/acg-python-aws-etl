terraform {
  backend "s3" {
    bucket = "nshipman-io-terraform-state"
    key = "acg-python-aws-etl/terraform.tfstate"
    region = "us-east-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.7.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

