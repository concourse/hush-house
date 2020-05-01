resource "kubernetes_namespace" "ci" {
  metadata {
    name = "ci"
  }
}

data "helm_repository" "concourse" {
  name = "concourse"
  url  = "https://concourse-charts.storage.googleapis.com"
}

resource "random_password" "encryption_key" {
    length = 32
    special = true
}

resource "random_password" "admin_password" {
    length = 32
    special = true
}

resource "tls_private_key" "host_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "template_file" "ci_values" {
  template = file("${path.module}/ci-values.yml.tpl")
  vars = {
    lb_address   = module.concourse_ci_address.address
    external_url = "http://${var.subdomain}.${var.domain}"

    github_client_id     = data.google_secret_manager_secret_version.github_client_id.secret_data
    github_client_secret = data.google_secret_manager_secret_version.github_client_secret.secret_data

    db_ip          = module.ci_database.ip
    db_user        = "atc"
    db_password    = module.ci_database.password
    db_ca_cert     = jsonencode(module.ci_database.ca_cert)
    db_cert        = jsonencode(module.ci_database.cert)
    db_private_key = jsonencode(module.ci_database.private_key)

    encryption_key = jsonencode(random_password.encryption_key.result)
    local_users    = jsonencode("admin:${random_password.admin_password.result}")

    host_key     = jsonencode(tls_private_key.host_key.private_key_pem)
    host_key_pub = jsonencode(tls_private_key.host_key.public_key_openssh)
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