global:
  tlsDisable: false
  tlsPostgresEnable: true
injector:
  enabled: false
server:
  nodeSelector: 'cloud.google.com/gke-nodepool: vault'
  extraContainers:
    - name: vault-init
      image: registry.hub.docker.com/sethvargo/vault-init:1.0.0
      imagePullPolicy: Always
      env:
        - name: CHECK_INTERVAL
          value: "10"
        - name: GCS_BUCKET_NAME
          value: "${gcs_bucket}"
        - name: "KMS_KEY_ID"
          value: "${crypto_key_id}"
  extraVolumes:
    - type: secret
      name: vault-server-tls
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