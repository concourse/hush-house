# Instantiates the GKE Kubernetes cluster.
#
module "cluster" {
  source = "../cluster"

  name   = "production"
  region = var.region
  zone   = var.zone

  release_channel = "STABLE"

  node_pools = {}
}

resource "local_file" "kubeconfig" {
  content  = module.cluster.kubeconfig
  filename = "${path.module}/kubeconfig"
}