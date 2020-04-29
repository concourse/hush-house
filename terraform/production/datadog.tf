data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "datadog" {
  namespace = kubernetes_namespace.datadog.id
  name       = "datadog"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "datadog"
  version    = "1.39.5"

  set {
    name = "datadog.datadog.useDogStatsDSocketVolume"
    value = true
  }

  # workaround "cannot re-use a name that is still in use"
  replace = true

# XXX: check on this later
#   set {
#     name = "kubeStateMetrics.enabled"
#     value = false
#   }
}