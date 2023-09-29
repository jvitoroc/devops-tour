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

variable "config_path" {
  type = string
}

variable "config_context" {
  type = string
}

variable "eks_role_arn" {
  type = string
}

provider "aws" {
  region = "us-east-1"
}

data "aws_availability_zones" "available" {}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 3)
  vpc_cidr = "10.0.0.0/16"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 4.0"

  name = "devops-tour"
  cidr = local.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
  intra_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.16.0"

  cluster_name                   = "devops-tour"
  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    ami_type       = "AL2_x86_64"
    instance_types = ["t3.large"]

    attach_cluster_primary_security_group = true
  }

  eks_managed_node_groups = {
    wg = {
      min_size     = 1
      max_size     = 2
      desired_size = 1

      instance_types = ["t3.large"]
      capacity_type  = "SPOT"
    }
  }
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

output "host" {
  value     = module.eks.cluster_endpoint
  sensitive = false
}

output "cluster_ca_certificate" {
  value     = base64decode(module.eks.cluster_certificate_authority_data)
  sensitive = false
}

resource "kubernetes_deployment" "api" {
  metadata {
    name = "api-deployment"
    labels = {
      app = "api"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "api"
      }
    }
    template {
      metadata {
        labels = {
          app = "api"
        }
      }
      spec {
        container {
          name              = "api"
          image             = "jvitoroc17/local:backend"
          image_pull_policy = "Always"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend-deployment"
    labels = {
      app = "frontend"
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "frontend"
      }
    }
    template {
      metadata {
        labels = {
          app = "frontend"
        }
      }
      spec {
        container {
          name              = "frontend"
          image             = "jvitoroc17/local:frontend"
          image_pull_policy = "Always"
          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name = "api"
  }
  spec {
    type = "NodePort"
    selector = {
      app = "api"
    }
    port {
      port        = 80
      target_port = 8080
    }
  }
}

resource "kubernetes_service" "frontend" {
  metadata {
    name = "frontend"
  }
  spec {
    type = "NodePort"
    selector = {
      app = "frontend"
    }
    port {
      port        = 80
      target_port = 8080
    }
  }
}

resource "kubernetes_ingress_v1" "api" {
  metadata {
    name = "api-ingress"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "api.devops-tour.com"
      http {
        path {
          backend {
            service {
              name = "api"
              port {
                number = 80
              }
            }
          }

          path = "/"
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "frontend" {
  metadata {
    name = "frontend-ingress"
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = "devops-tour.com"
      http {
        path {
          backend {
            service {
              name = "frontend"
              port {
                number = 80
              }
            }
          }

          path = "/"
        }
      }
    }
  }
}
