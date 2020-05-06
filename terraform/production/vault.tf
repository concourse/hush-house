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
    common_name = "vault_ca"
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

  dns_names = [
    "vault.vault.svc.cluster.local",
    "127.0.0.1",
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

resource "google_service_account" "production_vault" {
  account_id   = "production-vault"
  display_name = "Production Vault"
  description  = "Used to operate Vault in our Production cluster."
}

resource "google_storage_bucket" "production_vault" {
  name = "concourse-production-vault"
  bucket_policy_only = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }

    condition {
      num_newer_versions = 3
    }
  }
}

resource "google_project_iam_member" "production_vault_policy" {
  for_each = {
    "kmsAdmin" = "roles/cloudkms.admin"
    "kmsEncrypt" = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  }

  role = each.value
  member = "serviceAccount:${google_service_account.production_vault.email}"
}

resource "google_storage_bucket_iam_member" "production_vault_policy" {
  bucket = google_storage_bucket.production_vault.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.production_vault.email}"
}

data "template_file" "vault_values" {
  template = file("${path.module}/vault-values.yml.tpl")
  vars = {
    key_ring_name   = google_kms_key_ring.vault.name
    crypto_key_name = google_kms_crypto_key.vault.name
    crypto_key_id   = google_kms_crypto_key.vault.id

    vault_ca_cert            = jsonencode(tls_self_signed_cert.vault_ca.cert_pem)
    vault_server_cert        = jsonencode(module.vault_server_cert.cert_pem)
    vault_server_private_key = jsonencode(module.vault_server_cert.private_key_pem)

    gcp_project = google_kms_key_ring.vault.project
    gcp_region  = google_kms_key_ring.vault.location
    gcs_bucket  = google_storage_bucket.production_vault.name
  }
}

resource "helm_release" "vault" {
  namespace  = kubernetes_namespace.vault.id
  name       = "vault"
  chart      = "../../helm/charts/vault-helm"

  values = [
    data.template_file.vault_values.rendered,
  ]

  depends_on = [
    module.cluster.node_pools,
    kubernetes_secret.vault_server_tls,
  ]
}