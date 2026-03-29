terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.34.0"
    }
  }
  backend "s3" {
    bucket = "devops-iac-ci"
    key    = "state/terraform.tfstate"
    region = "us-east-2"
  }
  
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "terraform-state" {
  bucket        = "devops-iac-ci"
  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    IAC = "True"
  }
}

resource "aws_s3_bucket_versioning" "terraform-state" {
  bucket = "devops-iac-ci"
  versioning_configuration {
    status = "Enabled"
  }
} 