locals {
  deploymentPrefix = "${var.project_name}-${var.env}-deployment"
  servicePrefix = "${var.project_name}-${var.env}-service"
}

resource "kubernetes_deployment" "api" {
  metadata {
    name = "${local.deploymentPrefix}-api"
    labels = {
      app = "api"
    }
    annotations = {
      "configmap.reloader.stakater.com/reload" = var.config_map_name
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
          image             = var.api_image
          image_pull_policy = "Always"
          port {
            container_port = 8080
          }
          env_from {
            config_map_ref {
              name = var.config_map_name
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = "${local.deploymentPrefix}-app"
    labels = {
      app = "app"
    }
    annotations = {
      "configmap.reloader.stakater.com/reload" = var.config_map_name
    }
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "app"
      }
    }
    template {
      metadata {
        labels = {
          app = "app"
        }
      }
      spec {
        container {
          name              = "app"
          image             = var.app_image
          image_pull_policy = "Always"
          port {
            container_port = 8080
          }
          env_from {
            config_map_ref {
              name = var.config_map_name
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name = "${local.servicePrefix}-api"
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

resource "kubernetes_service" "app" {
  metadata {
    name = "${local.servicePrefix}-app"
  }
  spec {
    type = "LoadBalancer"
    selector = {
      app = "app"
    }
    port {
      port        = 80
      target_port = 8080
    }
  }
}