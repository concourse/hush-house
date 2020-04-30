resource "kubernetes_namespace" "ci" {
  metadata {
    name = "ci"
  }
}

data "helm_repository" "concourse" {
  name = "concourse"
  url  = "https://concourse-charts.storage.googleapis.com"
}

data "template_file" "ci_values" {
  template = file("${path.module}/ci-values.yml.tpl")
  vars = {
    lb_address = module.concourse_ci_address.address
  }
}

resource "helm_release" "ci-concourse" {
  namespace  = kubernetes_namespace.ci.id
  name       = "concourse"
  repository = data.helm_repository.concourse.metadata[0].name
  chart      = "concourse"
  version    = "9.1.1"

  values = [
    template_file.template_file.rendered,
  ]

  depends_on = [
    module.cluster.node_pools,
  ]
}