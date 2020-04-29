provider "kubernetes" {
  load_config_file = "false"

  host = "https://${module.cluster.endpoint}"

  client_certificate = base64decode(module.cluster.client_certificate)
  client_key = base64decode(module.cluster.client_key)
  cluster_ca_certificate = base64decode(module.cluster.cluster_ca_certificate)
}

# resource "kubernetes_namespace" "ci" {
#   metadata {
#     name = "ci"
#   }
# }

# resource "kubernetes_namespace" "datadog" {
#   metadata {
#     name = "datadog"
#   }
# }

resource "kubernetes_pod" "nginx" {
  metadata {
    name = "nginx-example"
    labels = {
      App = "nginx"
    }
  }

  spec {
    container {
      image = "nginx:1.7.8"
      name  = "example"

      port {
        container_port = 80
      }
    }
  }

  depends_on = [
    module.cluster.node_pools,
  ]
}