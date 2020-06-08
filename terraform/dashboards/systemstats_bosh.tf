#####################################################
# RESOURCES - DASHBOARDS - SYSTEM STATS - BOSH
#####################################################

resource "datadog_dashboard" "concourse_systemstats_bosh" {
  count        = var.deployment_tool == "bosh" ? 1 : 0
  is_read_only = false
  layout_type  = "ordered"
  notify_list  = []
  title        = "${var.dashboard_title} - System Stats"

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
      title       = "System Stats"

      widget {

        timeseries_definition {
          show_legend = false
          title       = "Web CPU Usage"

          request {
            display_type = "line"

            process_query {
              filter_by = [
                "command:concourse",
                "$environment",
                "$web",
              ]
              limit  = 10
              metric = "process.stat.cpu.user_pct.norm"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "cool"
            }
          }
          request {
            display_type = "line"

            process_query {
              filter_by = [
                "command:concourse",
                "$environment",
                "$web",
              ]
              limit  = 10
              metric = "process.stat.cpu.system_pct.norm"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "warm"
            }
          }

          yaxis {
            include_zero = false
            max          = "100"
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "Web Memory Usage"

          request {
            display_type = "line"
            q            = "avg:system.mem.used{$web,$environment} by {host}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "cool"
            }
          }
          request {
            display_type = "line"
            q            = "avg:system.swap.used{$web,$environment} by {host}"

            metadata {
              alias_name = "swap"
              expression = "avg:system.swap.used{$web,$environment} by {host}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "warm"
            }
          }
          request {
            display_type = "line"
            q            = "avg:system.mem.total{$web,$environment}"

            metadata {
              alias_name = "total"
              expression = "avg:system.mem.total{$web,$environment}"
            }

            style {
              line_type  = "dotted"
              line_width = "normal"
              palette    = "warm"
            }
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "Worker CPU Usage"

          request {
            display_type = "line"
            q            = "avg:system.cpu.user{$environment,$worker} by {bosh_id}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "cool"
            }
          }
          request {
            display_type = "line"
            q            = "avg:system.cpu.system{$environment,$worker} by {bosh_id}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "warm"
            }
          }

          yaxis {
            include_zero = false
            max          = "100"
          }
        }
      }
      widget {

        heatmap_definition {
          title = "Worker Memory Usage"

          request {
            q = "((avg:system.mem.total{$environment,$worker} by {bosh_id}-avg:system.mem.usable{$environment,$worker} by {bosh_id})/avg:system.mem.total{$environment,$worker} by {bosh_id})*100"

            style {
              palette = "grey"
            }
          }

          yaxis {
            include_zero = false
            max          = "100"
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "Web Network In"

          request {
            display_type = "area"
            q            = "avg:system.net.bytes_rcvd{$environment} by {bosh_name}"

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
          title       = "Web Network Out"

          request {
            display_type = "area"
            q            = "avg:system.net.bytes_sent{$environment} by {bosh_name}"

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
          title       = "DB CPU Usage"

          request {
            display_type = "area"
            q            = "avg:system.cpu.idle{$environment,bosh_job:db}, avg:system.cpu.user{$environment,bosh_job:db}, avg:system.cpu.guest{$environment,bosh_job:db}, avg:system.cpu.iowait{$environment,bosh_job:db}, avg:system.cpu.stolen{$environment,bosh_job:db}, avg:system.cpu.system{$environment,bosh_job:db}"

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }

          yaxis {
            include_zero = false
            max          = "100"
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "DB Memory Usage"

          request {
            display_type = "line"
            q            = "avg:system.mem.used{$environment,bosh_job:db}-avg:system.mem.cached{$environment,bosh_job:db}"

            metadata {
              alias_name = "used"
              expression = "avg:system.mem.used{$environment,bosh_job:db}-avg:system.mem.cached{$environment,bosh_job:db}"
            }

            style {
              line_type  = "solid"
              line_width = "normal"
              palette    = "dog_classic"
            }
          }
          request {
            display_type = "line"
            q            = "avg:system.mem.total{$environment,bosh_job:db}"

            metadata {
              alias_name = "total"
              expression = "avg:system.mem.total{$environment,bosh_job:db}"
            }

            style {
              line_type  = "dotted"
              line_width = "normal"
              palette    = "orange"
            }
          }
        }
      }
      widget {

        timeseries_definition {
          show_legend = false
          title       = "DB Disk Usage"

          request {
            display_type = "line"
            q            = "avg:system.disk.used{$environment,device:/var/vcap/store,job:db}"

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
}
