global:
  tlsDisable: false
injector:
  enabled: false
server:
  annotations:
    update: "1"
  nodeSelector: 'cloud.google.com/gke-nodepool: vault'
  extraVolumes:
    - type: secret
      name: vault-server-tls
  extraEnvironmentVariables:
    VAULT_CACERT="/vault/userconfig/vault-server-tls/vault.ca"
  standalone:
    enabled: true
    config: |
      ui = true

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
        region     = "${gcp_region}"
        key_ring   = "${key_ring_name}"
        crypto_key = "${crypto_key_name}"
      }

ui:
  enabled: true
  externalPort: 8200

ca: ${vault_ca_cert}
crt: ${vault_server_cert}
key: ${vault_server_private_key}