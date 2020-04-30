# Leaving commented out for now. We'll need to expose the dns name of our DNS managed zone
# in order to access it through terraform_remote_state.
#
# data "terraform_remote_state" "iaas" {
#   backend = "gcs"
#   config = {
#     // Do we need credentials + project + region here, or will it inherit from
#     // the provider we defined in gcp.tf?
#     bucket = "concourse-tf-state"
#     prefix = "terraform/state"
#   }
# }

# Reserves an address for `ci-test.concourse-ci.org` and ties it
# to the given domain.
#
module "concourse_ci_address" {
  source = "../address"

  dns_zone  = var.dns_zone
  subdomain = var.subdomain
}