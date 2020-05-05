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

resource "tls_private_key" "vault_ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "vault_ca" {
  key_algorithm   = tls_private_key.vault_ca.algorithm
  private_key_pem = tls_private_key.vault_ca.private_key_pem

  subject {
    common_name = "vault-ca"
  }

  validity_period_hours = 8760
  is_ca_certificate     = true

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}

module "vault_server_cert" {
  source = "../cert"

  common_name  = "vault.vault.svc.cluster.local"
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  ca_key_algorithm   = tls_private_key.vault_ca.algorithm
  ca_cert_pem        = tls_self_signed_cert.vault_ca.cert_pem
  ca_private_key_pem = tls_private_key.vault_ca.private_key_pem
}

module "vault_client_cert" {
  source = "../cert"

  common_name  = "concourse"
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]

  ca_key_algorithm   = tls_private_key.vault_ca.algorithm
  ca_cert_pem        = tls_self_signed_cert.vault_ca.cert_pem
  ca_private_key_pem = tls_private_key.vault_ca.private_key_pem
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

    vault_ca_cert            = jsonencode(tls_self_signed_cert.vault_ca.cert_pem)
    vault_server_cert        = jsonencode(module.vault_server_cert.cert_pem)
    vault_server_private_key = jsonencode(module.vault_server_cert.private_key_pem)
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
    kubernetes_secret.vault_postgres,
    kubernetes_secret.vault_gcp,
    kubernetes_secret.vault_server_tls,
  ]
}