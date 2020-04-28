provider "helm" {
  kubernetes {
    load_config_file = false

    host     = module.cluster.host

    client_certificate     = module.cluster.client_certificate
    client_key             = module.cluster.client_key
    cluster_ca_certificate = module.cluster.cluster_ca_certificate
  }
}