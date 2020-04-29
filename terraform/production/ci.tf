# data "helm_repository" "concourse" {
#   name = "concourse"
#   url  = "https://concourse-charts.storage.googleapis.com"
# }

# resource "helm_release" "ci-concourse" {
#   namespace  = kubernetes_namespace.ci.id
#   name       = "concourse"
#   repository = data.helm_repository.concourse.metadata[0].name
#   chart      = "concourse"
#   version    = "9.1.1"

#   values = [
#     file("${path.module}/ci-values.yml")
#   ]

#   # workaround "cannot re-use a name that is still in use"
#   replace = true
# }