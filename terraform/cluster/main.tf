module "vpc" {
  source = "./vpc"

  name   = var.name
  region = var.region

  vms-cidr      = "10.10.0.0/16"
  pods-cidr     = "10.11.0.0/16"
  services-cidr = "10.12.0.0/16"
}

resource "random_string" "password" {
  length  = 32
  special = true
}

resource "google_container_cluster" "main" {
  name     = var.name
  location = var.zone

  network    = module.vpc.name
  subnetwork = module.vpc.subnet-name

  remove_default_node_pool = true
  initial_node_count       = 1
  min_master_version       = "1.12.5-gke.5"

  ip_allocation_policy {
    cluster_secondary_range_name  = module.vpc.pods-range-name
    services_secondary_range_name = module.vpc.services-range-name
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }

    horizontal_pod_autoscaling {
      disabled = false
    }

    network_policy_config {
      disabled = false
    }
  }

  master_auth {
    username = "concourse"
    password = random_string.password.result

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  network_policy {
    provider = "CALICO"
    enabled = true
  }
}

resource "google_container_node_pool" "main" {
  provider = google-beta
  for_each = var.node-pools

  location = var.zone
  cluster  = google_container_cluster.main.name
  name     = each.key

  autoscaling {
    min_node_count = each.value.min
    max_node_count = each.value.max
  }

  management {
    auto_repair  = true
    auto_upgrade = each.value.auto-upgrade
  }

  node_config {
    preemptible     = each.value.preemptible
    machine_type    = each.value.machine-type
    local_ssd_count = each.value.local-ssds
    disk_size_gb    = each.value.disk-size
    disk_type       = each.value.disk-type
    image_type      = each.value.image

    workload_metadata_config {
      node_metadata = "SECURE"
    }

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "compute-rw",
      "storage-ro",
      "logging-write",
      "monitoring",
    ]
  }

  timeouts {
    create = "30m"
    delete = "30m"
  }
}
