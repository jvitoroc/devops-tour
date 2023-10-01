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