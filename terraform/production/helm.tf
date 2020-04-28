provider "helm" {
  kubernetes {
    load_config_file = false

    host     = module.cluster.host
    username = module.cluster.username
    password = module.cluster.password

    cluster_ca_certificate = module.cluster.cluster_ca_certificate
  }
}