#####################################################
# PROVIDERS
#####################################################

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  version = "~> 2.7"
}

#####################################################
# RESOURCES - DASHBOARDS
#####################################################

resource "datadog_dashboard" "concourse" {
  is_read_only = false
  layout_type  = "ordered"
  notify_list  = []
  title        = var.dashboard_title

  template_variable {
    default = local.environment_label_value
    name    = "environment"
    prefix  = local.environment_label_key
  }
  template_variable {
    default = local.web_label_value
    name    = "web"
    prefix  = local.web_label_key
  }
  template_variable {
    default = local.worker_label_value
    name    = "worker"
    prefix  = local.worker_label_key
  }

  widget {

    group_definition {
      layout_type = "ordered"
      title       = "Web Nodes"

      widget {

        heatmap_definition {
          title = "Scheduling By Job"

          request {
            q = "avg:${local.metrics_prefix}scheduling_job_duration_ms{$environment} by {job,job_id}"

            style {
              palette = "dog_classic"
            }
          }

          yaxis {
            include_zero = false
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "Total Time Scheduling Jobs"

          request {
            display_type = "line"
            q            = "sum:${local.metrics_prefix}scheduling_job_duration_ms{$environment}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          yaxis {
            include_zero = false
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "Garbage Collection"

          marker {
            display_type = "warning dashed"
            value        = "y > 10000"
          }
          marker {
            display_type = "error dashed"
            value        = "y > 60000"
          }

          request {
            display_type = "line"
            q            = "max:${local.metrics_prefix}gc_build_collector_duration_ms{$environment}"

            metadata {
              alias_name = "builds"
              expression = "max:${local.metrics_prefix}gc_build_collector_duration_ms{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
          request {
            display_type = "line"
            q            = "max:${local.metrics_prefix}gc_volume_collector_duration_ms{$environment}"

            metadata {
              alias_name = "volumes"
              expression = "max:${local.metrics_prefix}gc_volume_collector_duration_ms{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
          request {
            display_type = "line"
            q            = "max:${local.metrics_prefix}gc_worker_collector_duration_ms{$environment}"

            metadata {
              alias_name = "workers"
              expression = "max:${local.metrics_prefix}gc_worker_collector_duration_ms{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
          request {
            display_type = "line"
            q            = "max:${local.metrics_prefix}gc_artifact_collector_duration_ms{$environment}"

            metadata {
              alias_name = "artifacts"
              expression = "max:${local.metrics_prefix}gc_artifact_collector_duration_ms{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
          request {
            display_type = "line"
            q            = "max:${local.metrics_prefix}gc_container_collector_duration_ms{$environment}"

            metadata {
              alias_name = "containers"
              expression = "max:${local.metrics_prefix}gc_container_collector_duration_ms{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
          request {
            display_type = "line"
            q            = "max:${local.metrics_prefix}gc_resource_cache_collector_duration_ms{$environment}"

            metadata {
              alias_name = "resource caches"
              expression = "max:${local.metrics_prefix}gc_resource_cache_collector_duration_ms{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
          request {
            display_type = "line"
            q            = "max:${local.metrics_prefix}gc_resource_config_collector_duration_ms{$environment}"

            metadata {
              alias_name = "resource configs"
              expression = "max:${local.metrics_prefix}gc_resource_config_collector_duration_ms{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
          request {
            display_type = "line"
            q            = "max:${local.metrics_prefix}gc_resource_cache_use_collector_duration_ms{$environment}"

            metadata {
              alias_name = "resource cache uses"
              expression = "max:${local.metrics_prefix}gc_resource_cache_use_collector_duration_ms{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
          request {
            display_type = "line"
            q            = "max:${local.metrics_prefix}gc_resource_config_check_session_collector_duration_ms{$environment}"

            metadata {
              alias_name = "rccs"
              expression = "max:${local.metrics_prefix}gc_resource_config_check_session_collector_duration_ms{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          yaxis {
            include_zero = false
            scale        = "log"
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "Build Durations"

          marker {
            display_type = "error dashed"
            value        = "y > 60000"
          }

          request {
            display_type = "line"
            q            = "avg:${local.metrics_prefix}build_finished{$environment} by {job}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          yaxis {
            include_zero = false
            scale        = "sqrt"
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "Builds Created"

          marker {
            display_type = "ok dashed"
            value        = "y > 50"
          }

          request {
            display_type = "line"
            q            = "derivative(max:${local.metrics_prefix}build_started{$environment}), robust_trend(derivative(max:${local.metrics_prefix}build_started{$environment}))"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          yaxis {
            include_zero = false
            min          = "0"
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "Build Status"

          marker {
            display_type = "ok dashed"
            value        = "y > 50"
          }

          request {
            display_type = "line"
            q            = "sum:${local.metrics_prefix}build_finished{$environment} by {build_status}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          yaxis {
            include_zero = false
            min          = "0"
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "DB Connections"

          marker {
            display_type = "error dashed"
            value        = "y > 50"
          }

          request {
            display_type = "line"
            q            = "max:${local.metrics_prefix}database_connections{$environment,connectionname:backend} by {host}, robust_trend(avg:${local.metrics_prefix}database_connections{$environment,connectionname:backend})"

            style {
              line_type  = "solid"
              line_width = "thin"
              palette    = "warm"
            }
          }
          request {
            display_type = "line"
            q            = "max:${local.metrics_prefix}database_connections{$environment,connectionname:api} by {host}"

            style {
              line_type  = "solid"
              line_width = "thin"
              palette    = "cool"
            }
          }
          request {
            display_type = "line"
            q            = "max:${local.metrics_prefix}database_connections{$environment,connectionname:gc} by {host}"

            style {
              line_type  = "solid"
              line_width = "thin"
              palette    = "grey"
            }
          }

          yaxis {
            include_zero = false
            max          = "64"
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "DB Queries"

          request {
            display_type = "bars"
            q            = "avg:${local.metrics_prefix}database_queries{$environment} by {host}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "HTTP Response Time"

          marker {
            display_type = "ok dashed"
            value        = "0 < y < 100"
          }
          marker {
            display_type = "warning dashed"
            value        = "y > 1000"
          }
          marker {
            display_type = "error dashed"
            value        = "y > 10000"
          }

          request {
            display_type = "line"
            q            = "avg:${local.metrics_prefix}http_response_time{$environment} by {route}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          yaxis {
            include_zero = false
            scale        = "log"
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "Locks Held"

          request {
            display_type = "bars"
            q            = "avg:${local.metrics_prefix}lock_held{$environment} by {type}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          yaxis {
            include_zero = false
            max          = "10"
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "Web Goroutines"

          request {
            display_type = "line"
            q            = "avg:${local.metrics_prefix}goroutines{$environment} by {host}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          yaxis {
            include_zero = true
            max          = "auto"
            min          = "auto"
            scale        = "linear"
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "Checks Started"

          request {
            display_type = "line"
            q            = "avg:${local.metrics_prefix}checks_started{$environment} by {host}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          yaxis {
            include_zero = true
            max          = "auto"
            min          = "auto"
            scale        = "linear"
          }
        }
      }
    }
  }
  widget {

    group_definition {
      layout_type = "ordered"
      title       = "Worker Nodes"

      widget {

        timeseries_definition {
          show_legend = false
          title       = "Worker Containers"

          marker {
            display_type = "error dashed"
            label        = "\u00a0max containers\u00a0"
            value        = "y = 256"
          }

          request {
            display_type = "line"
            q            = "avg:${local.metrics_prefix}worker_containers{$environment} by {worker}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          yaxis {
            include_zero = false
            max          = "256"
          }
        }
      }
      widget {

        heatmap_definition {
          title = "Worker Volumes"

          request {
            q = "avg:${local.metrics_prefix}worker_volumes{$environment} by {worker}"

            style {
              palette = "grey"
            }
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "Worker States"

          request {
            display_type = "area"
            q            = "avg:${local.metrics_prefix}worker_state{$environment} by {state}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "grey"
            }
          }
        }
      }
    }
  }
  widget {

    group_definition {
      layout_type = "ordered"
      title       = "Containers and Volumes"

      widget {

        timeseries_definition {
          show_legend = false
          title       = "Containers to be GC'd"

          request {
            display_type = "line"
            q            = "avg:${local.metrics_prefix}created_containers_to_be_garbage_collected{$environment}"

            metadata {
              alias_name = "created"
              expression = "avg:${local.metrics_prefix}created_containers_to_be_garbage_collected{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "cool"
            }
          }
          request {
            display_type = "line"
            q            = "avg:${local.metrics_prefix}failed_containers_to_be_garbage_collected{$environment}"

            metadata {
              alias_name = "failed"
              expression = "avg:${local.metrics_prefix}failed_containers_to_be_garbage_collected{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "orange"
            }
          }
          request {
            display_type = "line"
            q            = "avg:${local.metrics_prefix}creating_containers_to_be_garbage_collected{$environment}"

            metadata {
              alias_name = "creating"
              expression = "avg:${local.metrics_prefix}creating_containers_to_be_garbage_collected{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "grey"
            }
          }
          request {
            display_type = "line"
            q            = "avg:${local.metrics_prefix}destroying_containers_to_be_garbage_collected{$environment}"

            metadata {
              alias_name = "destroying"
              expression = "avg:${local.metrics_prefix}destroying_containers_to_be_garbage_collected{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "purple"
            }
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "Volumes to be GC'd"

          request {
            display_type = "line"
            q            = "avg:${local.metrics_prefix}created_volumes_to_be_garbage_collected{$environment}"

            metadata {
              alias_name = "created"
              expression = "avg:${local.metrics_prefix}created_volumes_to_be_garbage_collected{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "cool"
            }
          }
          request {
            display_type = "line"
            q            = "avg:${local.metrics_prefix}failed_volumes_to_be_garbage_collected{$environment}"

            metadata {
              alias_name = "failed"
              expression = "avg:${local.metrics_prefix}failed_volumes_to_be_garbage_collected{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "orange"
            }
          }
          request {
            display_type = "line"
            q            = "avg:${local.metrics_prefix}orphaned_volumes_to_be_garbage_collected{$environment}"

            metadata {
              alias_name = "orphaned"
              expression = "avg:${local.metrics_prefix}orphaned_volumes_to_be_garbage_collected{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "grey"
            }
          }
          request {
            display_type = "line"
            q            = "avg:${local.metrics_prefix}destroying_volumes_to_be_garbage_collected{$environment}"

            metadata {
              alias_name = "destroying"
              expression = "avg:${local.metrics_prefix}destroying_volumes_to_be_garbage_collected{$environment}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "purple"
            }
          }
        }
      }
    }
  }
}

#####################################################
# LOCALS
#####################################################

locals {

  metrics_prefix = var.concourse_datadog_prefix == "" ? "" : "${var.concourse_datadog_prefix}."

  environment_label       = split(":", lookup(var.filter_by, "concourse_instance"))
  environment_label_key   = local.environment_label[0]
  environment_label_value = local.environment_label[1]

  web_label       = split(":", lookup(var.filter_by, "concourse_web"))
  web_label_key   = local.web_label[0]
  web_label_value = local.web_label[1]

  worker_label       = split(":", lookup(var.filter_by, "concourse_worker"))
  worker_label_key   = local.worker_label[0]
  worker_label_value = local.worker_label[1]
}
