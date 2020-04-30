data "google_secret_manager_secret_version" "github_client_id" {
  provider = google-beta
  secret = "production-ci-github_client_id"
}

data "google_secret_manager_secret_version" "github_client_secret" {
  provider = google-beta
  secret = "production-ci-github_client_secret"
}