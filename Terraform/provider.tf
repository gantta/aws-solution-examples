terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.36.0"
    }
    github = {
      source = "integrations/github"
      version = "4.8.0"
    }
  }
  backend "s3" {
      bucket = "gantta-terraform"
      key    = "tfstate/aws-solution-example/dev.tfstate"
      region = "us-east-2"
  }
}

provider "aws" {
  # Configuration options
  region = var.region
}

provider "github" {
  token = var.GITHUB_PAT
  owner = "gantta"
}