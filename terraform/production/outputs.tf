output cluster_name {
  value = module.cluster.name
}

output cluster_zone {
  value = module.cluster.location
}

output project {
  value = var.project
}

output vault_namespace {
  value = kubernetes_namespace.vault.id
}

output vault_crypto_key_self_link {
  value = google_kms_crypto_key.vault.self_link
}

output vault_ca_cert {
  value = tls_self_signed_cert.vault_ca.cert_pem
}