data "template_file" "kubeconfig" {
  template = file("${path.module}/kubeconfig-template.yml")

  vars = {
    cluster_name    = module.cluster.name
    user_name       = module.cluster.username
    user_password   = module.cluster.password
    endpoint        = module.cluster.endpoint
    cluster_ca      = module.cluster.cluster_ca_certificate
  }
}

resource "local_file" "kubeconfig" {
  content  = data.template_file.kubeconfig.rendered
  filename = "${path.module}/kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = "${path.module}/kubeconfig"
  }
}