resource "kubernetes_ingress_v1" "api" {
  metadata {
    name = "devops-tour-ingress-api"
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

resource "kubernetes_ingress_v1" "frontend" {
  metadata {
    name = "devops-tour-ingress-frontend"
    annotations = var.annotations
  }

  spec {
    ingress_class_name = var.class_name

    rule {
      host = var.frontend_host
      http {
        path {
          path_type = "Prefix"
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