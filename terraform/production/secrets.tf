data "google_secret_manager_secret_version" "github_client_id" {
  provider = google-beta
  secret = "production-ci-github_client_id"
}

data "google_secret_manager_secret_version" "github_client_secret" {
  provider = google-beta
  secret = "production-ci-github_client_secret"
}

resource "google_secret_manager_secret" "admin_password" {
  provider = google-beta

  secret_id = "production-ci-admin_password"

  labels = {
    cluster    = "production"
    deployment = "ci"
  }

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "admin_password" {
  provider = google-beta

  secret = google_secret_manager_secret.admin_password.id
  secret_data = random_password.admin_password.result
}