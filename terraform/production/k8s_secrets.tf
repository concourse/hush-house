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