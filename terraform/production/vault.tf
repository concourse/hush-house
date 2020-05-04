resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "google_kms_key_ring" "vault" {
  name     = "production-vault-unseal-kr"
  location = "global"
}

resource "google_kms_crypto_key" "vault" {
  name            = "production-vault-unseal-key"
  key_ring        = google_kms_key_ring.vault.self_link

  lifecycle {
    prevent_destroy = true
  }
}

# Creates the CloudSQL Postgres database to be used by `vault`
#
module "vault_database" {
  source = "../database"

  name            = "vault"
  cpus            = "4"
  disk_size_gb    = "10"
  memory_mb       = "5120"
  region          = "${var.region}"
  zone            = "${var.zone}"
  max_connections = "100"
}

data "template_file" "vault_values" {
  template = file("${path.module}/vault-values.yml.tpl")
  vars = {
    key_ring = google_kms_key_ring.vault.id
    crypto_key = google_kms_crypto_key.vault.id

    gcp_service_account_key = jsonencode(var.credentials)

    db_ip          = module.vault_database.ip
    db_user        = "atc"
    db_password    = module.vault_database.password
    db_ca_cert     = jsonencode(module.vault_database.ca_cert)
    db_cert        = jsonencode(module.vault_database.cert)
    db_private_key = jsonencode(module.vault_database.private_key)
  }
}

resource "helm_release" "vault" {
  namespace  = kubernetes_namespace.vault.id
  name       = "vault"
  chart      = "../../helm/charts/vault"

  values = [
    data.template_file.vault_values.rendered,
  ]

  depends_on = [
    module.cluster.node_pools,
  ]
}