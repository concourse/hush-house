global:
  tlsDisable: false
  tlsPostgresEnable: true
server:
  nodeSelector: 'cloud.google.com/gke-nodepool: generic-1'
  extraVolumes:
    - type: secret
      name: vault-server-tls
    - type: secret
      name: vault-gcp
    - type: secret
      name: postgres
  extraEnvironmentVars:
    GOOGLE_REGION: global
    GOOGLE_PROJECT: cf-concourse-production
    GOOGLE_APPLICATION_CREDENTIALS: /vault/userconfig/vault-gcp/vault.gcp
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

      storage "postgresql" {
        connection_url = "host=%POSTGRES_IP% port=5432 user=%POSTGRES_USER% password=%POSTGRES_SECRET% sslkey=/vault/postgres/postgres-client.key sslcert=/vault/postgres/postgres-client.crt sslrootcert=/vault/postgres/postgres.ca dbname=vault"
      }

      seal "gcpckms" {
        key_ring = "${key_ring}"
        crypto_key = "${crypto_key}"
      }

gcp: ${gcp_service_account_key}

postgres:
  ip: ${db_ip}
  user: ${db_user}
  secret: ${db_password}
  ca: ${db_ca_cert}
  crt: ${db_cert}
  key: ${db_private_key}