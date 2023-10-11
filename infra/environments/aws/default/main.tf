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
  source = "../../../modules/eks"

  project_name = var.name
  env          = var.env
}

module "alb_controller" {
  source = "../../../modules/alb-controller"

  cluster_name          = module.eks.cluster_name
  eks_oidc_provider_arn = module.eks.oidc_provider_arn
}

module "parameters" {
  source = "../../../modules/parameters"

  project_name = var.name
  env          = var.env
}

locals {
  env_vars = {
    for i, param in module.parameters.env_vars_params :
    format("%s%s", "DEV_OPS_", upper(element(split("/", param.name), length(split("/", param.name)) - 1))) => param.value
  }
}

module "configmap" {
  source = "../../../modules/configmap"

  env_vars     = local.env_vars
  project_name = var.name
  env          = var.env
}

module "services" {
  source = "../../../modules/services"

  config_map_name = module.configmap.name
  project_name    = var.name
  env             = var.env
  api_image       = module.parameters.api_image
  app_image       = module.parameters.app_image
}

module "ingress" {
  source = "../../../modules/ingress"

  annotations = {
    "kubernetes.io/ingress.class" : "alb",
    "alb.ingress.kubernetes.io/scheme" : "internet-facing"
  }
  class_name   = "alb"
  project_name = var.name
  env          = var.env
}

module "reloader" {
  source = "../../../modules/reloader"
}
