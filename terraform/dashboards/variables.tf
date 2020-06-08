#################################
# VARIABLES
#################################

variable "datadog_api_key" {
  type        = string
  description = "Datadog API key."
}
variable "datadog_app_key" {
  type        = string
  description = "Datadog APP key."
}

variable "dashboard_title" {
  type        = string
  description = "Title of the dashboards."
}

variable "concourse_datadog_prefix" {
  type        = string
  default     = ""
  description = "Value passed (if any) to CONCOURSE_DATADOG_PREFIX variable in your Concourse deployment."
}

variable "filter_by" {
  type        = map(string)
  description = "Set of tags that identify your Concourse deployment, web node and worker nodes."
}

variable "deployment_tool" {
  type        = string
  description = "Tool used to deploy Concourse (either `bosh` or `helm`)."
}
