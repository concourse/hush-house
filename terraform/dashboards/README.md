## Terraform Module for creating Datadog dashboards for a Concourse deployment

This module uses [Terraform Datadog provider](https://www.terraform.io/docs/providers/datadog/index.html) to interact with the `dashboard_resource` supported by Datadog. It creates two separate dashboards:
1. A dashboard that displays a set of graphs/widgets to allow for observing how Concourse is behaving and performing.
1. A system statistics dashboard that displays metrics from the base system your Concourse is deployed on. It slightly varies depending on the tool used to deploy Concourse (either `bosh` or `helm`).

### Module Inputs

In order to create dashboards with this module, one or more variables should be set.

* `datadog_api_key`: *Required.* Datadog API key.
* `datadog_app_key`: *Required.* Datadog APP key.
* `dashboard_title`: *Required.* Title of the dashboards.
* `concourse_datadog_prefix`: *Optional.* Set this variable in case your Concourse metrics were set with a prefix.
* `deployment_tool`: *Required.* Tool utilized to deploy Concourse (either `bosh` or `helm`).
* `filter_by`: *Required.* This variable is a map of strings which is expected to be set with three keys:

    **concourse_instance** - tag used to identify your Concourse deployment. _e.g._ "environment:hush-house"
    **concourse_web** - tag used to identify your Concourse web nodes.
    **concourse_worker** - tag used to identify your Concourse worker nodes. _P.S._ Refer to [examples/main.tf](./examples/main.tf) for an example on how to set this variable.

### Module Outputs

This module has no output variables.

### Usage

Once the `dashboards` module is called from your Terraform root module as [our example](./examples/main.tf) illustrates, you can run the following commands to create the dashboards:

```shell script
terraform init
terraform apply
