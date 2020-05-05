resource "kubernetes_secret" "vault_postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.vault.id
  }

  data = {
    "postgres.ca" = module.vault_database.ca_cert
    "postgres-client.crt" = module.vault_database.cert
    "postgres-client.key" = module.vault_database.private_key
    "postgres.ip" = module.vault_database.ip
    "postgres.user" = module.vault_database.user
    "postgres.secret" = module.vault_database.password
  }
}

resource "kubernetes_secret" "vault_server_tls" {
  metadata {
    name      = "vault-server-tls"
    namespace = kubernetes_namespace.vault.id
  }

  data = {
    "vault.ca" = tls_self_signed_cert.vault_ca.cert_pem
    "vault.crt" = module.vault_server_cert.cert_pem
    "vault.key" = module.vault_server_cert.private_key_pem
  }
}