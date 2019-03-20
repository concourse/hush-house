resource "random_id" "instance-name" {
  byte_length = 4
}

resource "google_sql_database_instance" "main" {
  name             = "${var.name}-${random_id.instance-name.hex}"
  region           = "${var.region}"
  database_version = "POSTGRES_9_6"

  settings {
    availability_type = "ZONAL"
    disk_autoresize   = true
    disk_size         = "10"
    disk_type         = "PD_SSD"
    tier              = "db-custom-${var.cpus}-${var.memory_mb}"

    ip_configuration {
      ipv4_enabled = "true"
      require_ssl  = "true"
    }

    backup_configuration {
      enabled    = true
      start_time = "23:00"
    }

    location_preference {
      zone = "${var.zone}"
    }
  }
}

resource "google_sql_database" "atc" {
  name = "atc"

  instance  = "${google_sql_database_instance.main.name}"
  charset   = "UTF8"
  collation = "en_US.UTF8"
}

resource "random_string" "password" {
  length  = 32
  special = true
}

resource "google_sql_user" "user" {
  name = "atc"

  instance = "${google_sql_database_instance.main.name}"
  password = "${random_string.password.result}"
}
