module "web-address" {
  source = "./address"

  dns-zone  = "${var.dns-zone}"
  subdomain = "hush-house"
}

module "metrics-address" {
  source = "./address"

  dns-zone  = "${var.dns-zone}"
  subdomain = "metrics-hush-house"
}

module "cluster" {
  source = "./cluster"

  name   = "hush-house"
  zone   = "${var.zone}"
  region = "${var.region}"

  node-pools = [
    {
      name         = "generic-1"
      min          = 1
      node_count   = 1
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
      name         = "workers-1"
      min          = 1
      node_count   = 4
      max          = 10
      local-ssds   = 0
      machine-type = "custom-16-32768"
      image        = "COS"
      disk-size    = "50"
      disk-type    = "pd-ssd"
      auto-upgrade = false
      preemptible  = false
      version      = "1.12.5-gke.5"
    },
  ]
}

module "database" {
  source = "./database"

  name      = "hush-house"
  cpus      = "4"
  memory_mb = "5120"
  region    = "${var.region}"
  zone      = "${var.zone}"
}
