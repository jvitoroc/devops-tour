locals {
  prefix = "${var.project_name}-${var.env}-ingress"
}

resource "kubernetes_ingress_v1" "api" {
  metadata {
    name = "${local.prefix}-api"
    annotations = var.annotations
  }

  spec {
    ingress_class_name = var.class_name
    
    rule {
      host = var.api_host
      http {
        path {
          path_type = "Prefix"
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

resource "kubernetes_ingress_v1" "app" {
  metadata {
    name = "${local.prefix}-app"
    annotations = var.annotations
  }

  spec {
    ingress_class_name = var.class_name

    rule {
      host = var.app_host
      http {
        path {
          path_type = "Prefix"
          backend {
            service {
              name = "app"
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