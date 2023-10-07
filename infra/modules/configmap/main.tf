locals {
  name = "environment-variables"
}

resource "kubernetes_config_map_v1" "configmap" {
  metadata {
    name = local.name
  }

  data = var.env_vars
}