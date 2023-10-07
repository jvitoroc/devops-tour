resource "helm_release" "reloader" {
  name = "reloader"

  repository = "https://stakater.github.io/stakater-charts"
  chart      = "reloader"
  namespace  = "kube-system"
}
