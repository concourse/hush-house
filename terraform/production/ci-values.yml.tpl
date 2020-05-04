image: concourse/concourse-rc
imageTag: 6.0.0-rc.41

postgresql:
  enabled: false

web:
  annotations:
    rollingUpdate: "3"
  replicas: 2
  nodeSelector:
    cloud.google.com/gke-nodepool: generic-1
  env:
  - name: CONCOURSE_X_FRAME_OPTIONS
    value: ""

  resources:
    requests:
      cpu: 1500m
      memory: 1Gi
    limits:
      cpu: 1500m
      memory: 1Gi

  service:
    type: LoadBalancer
    loadBalancerIP: ${lb_address}

persistence:
  worker:
    storageClass: ssd
    size: 750Gi

worker:
  replicas: 2
  annotations:
    manual-update-revision: "1"
  terminationGracePeriodSeconds: 3600
  livenessProbe:
    periodSeconds: 60
    failureThreshold: 10
    timeoutSeconds: 45
  hardAntiAffinity: true
  env:
  - name: CONCOURSE_GARDEN_NETWORK_POOL
    value: "10.254.0.0/16"
  - name: CONCOURSE_GARDEN_MAX_CONTAINERS
    value: "500"
  - name: CONCOURSE_GARDEN_DENY_NETWORK
    value: "169.254.169.254/32"
  resources:
    limits:   { cpu: 7500m, memory: 14Gi }
    requests: { cpu: 0m,    memory: 0Gi  }

concourse:
  web:
    auth:
      mainTeam:
        localUser: admin
        github:
          team: concourse:Pivotal
      github:
        enabled: true
    externalUrl: ${external_url}
    bindPort: 80
    clusterName: ci
    containerPlacementStrategy: limit-active-tasks
    maxActiveTasksPerWorker: 5
    enableGlobalResources: true
    # encryption: { enabled: true }
    kubernetes:
      keepNamespaces: false
      enabled: false
      createTeamNamespaces: false

    letsEncrypt: { enabled: true, acmeURL: "https://acme-v02.api.letsencrypt.org/directory" }
    tls: { enabled: true, bindPort: 443 }

    postgres:
      host: ${db_ip}
      database: atc
      sslmode: verify-ca
  worker:
    rebalanceInterval: 2h
    baggageclaim: { driver: overlay }
    healthcheckTimeout: 40s

secrets:
  githubClientId: ${github_client_id}
  githubClientSecret: ${github_client_secret}

  postgresUser: ${db_user}
  postgresPassword: ${db_password}
  postgresCaCert: ${db_ca_cert}
  postgresClientCert: ${db_cert}
  postgresClientKey: ${db_private_key}

  encryptionKey: ${encryption_key}
  localUsers: ${local_users}

  hostKey: ${host_key}
  hostKeyPub: ${host_key_pub}

  workerKey: ${worker_key}
  workerKeyPub: ${worker_key_pub}

  sessionSigningKey: ${session_signing_key}

  vaultCaCert: ${vault_ca_cert}
  vaultClientCert: ${vault_client_cert}
  vaultClientKey: ${vault_client_private_key}