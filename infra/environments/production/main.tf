terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "4.66.1"
    }
  }
}

provider "aws" {
  region = var.region
}

module "eks" {
    source = "../../modules/eks"

    cluster_name = var.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
  }
}

module "services" {
    source = "../../modules/services"
}