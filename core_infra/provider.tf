provider "aws" {
  region = "ap-southeast-2"
}

terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.41"
    }
    archive = {
      source = "hashicorp/archive"
    }
  }
  required_version = ">= 1.0.6"
}