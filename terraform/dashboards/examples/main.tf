module "ci_dashboard" {
  source = "./dashboards"

  datadog_api_key = "your datadog api key"
  datadog_app_key = "your datadog app key"

  dashboard_title = "Concourse Dashboard - CI"

  deployment_tool = "helm"

  concourse_datadog_prefix = "concourse.ci"

  filter_by = {
    concourse_instance = "environment:ci"
    concourse_web      = "kube_deployment:ci-web"
    concourse_worker   = "kube_stateful_set:ci-worker"
  }
}

module "hush_house_dashboard" {
  source = "./dashboards"

  datadog_api_key = "your datadog api key"
  datadog_app_key = "your datadog app key"

  dashboard_title = "Concourse Dashboard - Hush House"

  deployment_tool = "helm"

  concourse_datadog_prefix = "concourse.ci"

  filter_by = {
    concourse_instance = "environment:hush-house"
    concourse_web      = "kube_deployment:hush-house-web"
    concourse_worker   = "kube_stateful_set:workers-worker"
  }
}

module "ci_bosh_dashboard" {
  source = "./dashboards"

  datadog_api_key = "your datadog api key"
  datadog_app_key = "your datadog app key"

  dashboard_title = "Concourse Dashboard - CI - BOSH"

  deployment_tool = "bosh"

  concourse_datadog_prefix = "concourse.ci"

  filter_by = {
    concourse_instance = "bosh-deployment:concourse-algorithm"
    concourse_web      = "bosh_job:web"
    concourse_worker   = "bosh_job:worker"
  }
}
