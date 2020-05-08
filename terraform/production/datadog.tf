# resource "kubernetes_namespace" "datadog" {
#   metadata {
#     name = "datadog"
#   }
# }

# resource "helm_release" "datadog" {
#   namespace = kubernetes_namespace.datadog.id
#   name       = "datadog"
#   repository = "https://kubernetes-charts.storage.googleapis.com"
#   chart      = "datadog"
#   version    = "1.39.5"

#   set {
#     name = "datadog.datadog.useDogStatsDSocketVolume"
#     value = true
#   }

#   # workaround "cannot re-use a name that is still in use"
#   replace = true

# # XXX: check on this later
# #   set {
# #     name = "kubeStateMetrics.enabled"
# #     value = false
# #   }

  # depends_on = [
  #   module.cluster.node_pools,
  # ]
# }