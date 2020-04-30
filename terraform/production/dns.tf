data "terraform_remote_state" "iaas" {
  backend = "gcs"
  config = {
    // Do we need credentials + project + region here, or will it inherit from
    // the provider we defined in gcp.tf?
    bucket = "concourse-tf-state"
    prefix = "terraform/state"
  }
}

# Reserves an address for `ci-test.concourse-ci.org` and ties it
# to the given domain.
#
module "concourse_ci_address" {
  source = "../address"

  dns_zone  = "${data.terraform_remote_state.iaas.google_dns_managed_zone.concourse-ci-org.dns_name}"
  subdomain = "ci-test"
}