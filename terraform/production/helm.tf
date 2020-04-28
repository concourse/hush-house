provider "helm" {
  kubernetes {
    host     = "https://${module.cluster.google_container_cluster.main.endpoint}"

    client_certificate     = module.cluster.google_container_cluster.master_auth[0].client_certificate
    client_key             = module.cluster.google_container_cluster.master_auth[0].client_key
    cluster_ca_certificate = module.cluster.google_container_cluster.master_auth[0].cluster_ca_certificate
  }
}