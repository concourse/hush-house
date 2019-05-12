# Reserved IP address for the `web` instances.
#
# This is needed so that we can have a static IP that `hush-house.pivotal.io`
# can point.
#
resource "google_compute_address" "hush-house" {
  name = "hush-house"
}

# Reserves an address for `metrics-hush-house.concourse-ci.org` and ties it
# to the given domain.
#
module "metrics-address" {
  source = "./address"

  dns-zone  = "${var.dns-zone}"
  subdomain = "metrics-hush-house"
}

# Instantiates the GKE Kubernetes cluster.
#
module "cluster" {
  source = "./cluster"

  name   = "hush-house"
  zone   = "${var.zone}"
  region = "${var.region}"

  node-pools = [
    {
      # The pool to be used by non-worker.
      #
      name = "generic-1"

      min          = 1
      node_count   = 2
      max          = 5
      local-ssds   = 0
      machine-type = "n1-standard-4"
      image        = "COS"
      disk-size    = "50"
      disk-type    = "pd-ssd"
      auto-upgrade = false
      preemptible  = false
      version      = "1.12.5-gke.5"
    },
    {
      # The pool to be exclusively used by `hush-house` Concourse workers
      #
      name = "workers-1"

      min          = 1
      node_count   = 5
      max          = 10
      local-ssds   = 0
      machine-type = "custom-16-32768"
      image        = "UBUNTU"
      disk-size    = "50"
      disk-type    = "pd-ssd"
      auto-upgrade = false
      preemptible  = false
      version      = "1.12.5-gke.5"
    },
  ]
}

# Creates the CloudSQL Postgres database to be used by the `hush-house`
# Concourse deployment.
#
module "database" {
  source = "./database"

  name      = "hush-house"
  cpus      = "4"
  memory_mb = "5120"
  region    = "${var.region}"
  zone      = "${var.zone}"
}
