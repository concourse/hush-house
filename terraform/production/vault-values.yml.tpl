global:
  tlsDisable: false
  tlsPostgresEnable: true
server:
  nodeSelector: 'cloud.google.com/gke-nodepool: vault'
  extraVolumes:
    - type: secret
      name: vault-server-tls
  standalone:
    enabled: true
    config: |
      listener "tcp" {
        address = "[::]:8200"
        cluster_address = "[::]:8201"
        tls_cert_file = "/vault/userconfig/vault-server-tls/vault.crt"
        tls_key_file  = "/vault/userconfig/vault-server-tls/vault.key"
        tls_client_ca_file = "/vault/userconfig/vault-server-tls/vault.ca"
      }

      storage "gcs" {
        bucket = "${gcs_bucket}"
      }

      seal "gcpckms" {
        project    = "${gcp_project}"
        key_ring   = "${key_ring}"
        crypto_key = "${crypto_key}"
      }

ca: ${vault_ca_cert}
crt: ${vault_server_cert}
key: ${vault_server_private_key}