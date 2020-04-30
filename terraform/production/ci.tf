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
    lb_address           = module.concourse_ci_address.address
    external_url         = "http://${var.subdomain}.${var.domain}"
    github_client_id     = data.google_secret_manager_secret_version.github_client_id.secret_data
    github_client_secret = data.google_secret_manager_secret_version.github_client_secret.secret_data
  }
}

resource "helm_release" "ci-concourse" {
  namespace  = kubernetes_namespace.ci.id
  name       = "concourse"
  repository = data.helm_repository.concourse.metadata[0].name
  chart      = "concourse"
  version    = "9.1.1"

  values = [
    data.template_file.ci_values.rendered,
  ]

  depends_on = [
    module.cluster.node_pools,
  ]
}