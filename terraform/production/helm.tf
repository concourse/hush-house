provider "helm" {
  kubernetes {
    load_config_file = false

    host  = "https://${module.cluster.endpoint}"
    token = data.google_client_config.current.access_token

    cluster_ca_certificate = base64decode(module.cluster.cluster_ca_certificate)
  }
}