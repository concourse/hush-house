provider "kubernetes" {
  load_config_file = "false"

  host = "https://${module.cluster.endpoint}"

  username = module.cluster.username
  password = module.cluster.password
  
  cluster_ca_certificate = module.cluster.cluster_ca_certificate
}

resource "kubernetes_namespace" "ci" {
  metadata {
    name = "ci"
  }
}

resource "kubernetes_namespace" "datadog" {
  metadata {
    name = "datadog"
  }
}