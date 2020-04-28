provider "helm" {
  kubernetes {
    config_path = local_file.kubeconfig.filename
  }
}