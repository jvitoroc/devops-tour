resource "kubernetes_deployment" "api" {
  metadata {
    name = "api-deployment"
    labels = {
      app = "api"
    }
    annotations = {
      "configmap.reloader.stakater.com/reload" = var.configmap_name
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
          env_from {
            config_map_ref {
              name = var.configmap_name
            }
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
    annotations = {
      "configmap.reloader.stakater.com/reload" = var.configmap_name
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
          env_from {
            config_map_ref {
              name = var.configmap_name
            }
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
    type = "LoadBalancer"
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
    type = "LoadBalancer"
    selector = {
      app = "frontend"
    }
    port {
      port        = 80
      target_port = 8080
    }
  }
}