data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "datadog" {
  namespace = "datadog"
  name       = "datadog"
  repository = data.helm_repository.stable.metadata[0].name
  chart      = "datadog"
  version    = "1.39.5"

  set {
    name = "datadog.datadog.useDogStatsDSocketVolume"
    value = true
  }

# XXX: check on this later
#   set {
#     name = "kubeStateMetrics.enabled"
#     value = true
#   }
}