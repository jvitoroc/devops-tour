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

module "parameters" {
  source = "../../modules/parameters"
}

locals {
  env_vars = {
    for i, param in module.parameters.params :
    format("%s%s", "DEV_OPS_", upper(element(split("/", param.name), length(split("/", param.name)) - 1))) => param.value
  }
}

module "configmap" {
  source = "../../modules/configmap"

  env_vars = local.env_vars
}

module "services" {
  source = "../../modules/services"

  configmap_name = module.configmap.name
}

module "ingress" {
  source = "../../modules/ingress"

  annotations = {
    "kubernetes.io/ingress.class" : "alb",
    "alb.ingress.kubernetes.io/scheme" : "internet-facing"
  }
  class_name = "alb"
}

module "reloader" {
  source = "../../modules/reloader"
}