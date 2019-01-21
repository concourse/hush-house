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

  name   = "hush-house-test"
  zone   = "${var.zone}"
  region = "${var.region}"

  node-pools = [
    {
      name         = "preemptible"
      min          = 1
      max          = 3
      local-ssds   = 1
      machine-type = "n1-standard-8"
      image        = "COS"
      disk-size    = "15"
      disk-type    = "pd-ssd"
      auto-upgrade = false
      preemptible  = true
      version      = "1.11.6-gke.2"
    },
  ]
}

module "database" {
  source = "./database"

  name      = "hush-house-test"
  cpus      = "4"
  memory_mb = "5120"
  region    = "${var.region}"
  zone      = "${var.zone}"
  vpc-uri   = "${module.cluster.vpc-uri}"
}
