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
    bucket         = "terraform-remote-state-jvitoroc"
    dynamodb_table = "terraform"
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}

provider "aws" {
  region = var.region
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

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
    }
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name = var.cluster_name
}

module "alb_controller" {
  source = "../../modules/alb-controller"

  cluster_name          = module.eks.cluster_name
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
}

module "services" {
  source = "../../modules/services"
}

module "ingress" {
  source = "../../modules/ingress"

  annotations = {
    "kubernetes.io/ingress.class": "alb",
    "alb.ingress.kubernetes.io/scheme": "internet-facing"
  }
  class_name = "alb"
}

resource "kubernetes_config_map" "example" {
  metadata {
    name = "my-config"
  }

  data = {
    api_host             = "myhost:443"
    db_host              = "dbhost:5432"
    "my_config_file.yml" = "${file("${path.module}/my_config_file.yml")}"
  }

  binary_data = {
    "my_payload.bin" = "${filebase64("${path.module}/my_payload.bin")}"
  }
}