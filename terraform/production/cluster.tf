# Instantiates the GKE Kubernetes cluster.
#
module "cluster" {
  source = "../cluster"

  name   = "production"
  region = var.region
  zone   = var.zone

  node-pools = {}
}
