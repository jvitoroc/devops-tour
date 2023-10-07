terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

provider "kubernetes" {
    config_path    = var.config_path
    config_context = var.config_context
}

module "services" {
    source = "../../modules/services"
}

module "ingress" {
  source = "../../modules/ingress"

  api_host = "api.devops-tour.com"
  frontend_host = "devops-tour.com"
  class_name = "nginx"
}