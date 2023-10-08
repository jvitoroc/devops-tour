terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "5.19.0"
    }
  }

  backend "s3" {
    bucket         = "devops-tour"
    dynamodb_table = "terraform-locks"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
  }
}

module "default" {
  source = "../default"

  env = "prod"
  region = var.region
  name = var.name
}