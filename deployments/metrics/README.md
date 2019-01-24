# Metrics

The `metrics` deployment consists of the whole configuration and stack for monitoring targets that run in the `hush-house` cluster.

It's composed of two dependent charts:

- [prometheus](https://github.com/helm/charts/blob/master/stable/prometheus/README.md); and
- [grafana](https://github.com/helm/charts/blob/master/stable/grafana/README.md).


## Prometheus

[Prometheus](https://prometheus.io/) enables us to have a place to store timeseries data regarding metrics that get exposed by services in the cluster.

It discovers these targets by looking at specific labels in Kubernetes objects (services and pods).


### Getting pods and service scraped

To have **services** from your deployment scraped by the Prometheus instance managed by this deployment, include the following labelset:

- `prometheus.io/scrape`: Activates scraping for the pod (required if you want to have scraping);
- `prometheus.io/path`: If the metrics path is not `/metrics` override this; and
- `prometheus.io/port`: If the metrics are exposed on a different port to the service then set this appropriately.

To have **pods** scraped:

- `prometheus.io/scrape`: Only scrape pods that have a value of `true`;
- `prometheus.io/path`: If the metrics path is not `/metrics` override this; and
- `prometheus.io/port`: Scrape the pod on the indicated port instead of the default of `9102`.


### Accessing the console

Not being publicly exposed, its console can be accessed through port-forwarding:

```sh
# Set up a local proxy that allows us to connect
# to the `metrics-prometheus-server` service by
# hitting `127.0.0.1:9090`.
kubectl port-forward \
	--namespace metrics \
	service/metrics-prometheus-server \
	9090:80
```

### Machine metrics

The deployment includes [`node-exporter`](https://github.com/prometheus/node_exporter) deployed as a [DaemonSet](https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/), making itself present in every node that is part of the cluster (except masters and tainted nodes not explicitly configured in the [`values.yaml` file](./values.yaml)).


### Kube state

Cluster-level metrics can be retrieved from [`kube-state`](https://github.com/kubernetes/kube-state-metrics), a component also deployed by the `metrics` deployment.


## Grafana

The [grafana](https://grafana.com/) instance is publicly accessible at [metrics-hush-house.concourse-ci.org](https://metrics-hush-house.concourse-ci.org).

This instance *does not* have persistence enabled so that no state needs to be kept around, having all of its panel configurations provisioned as [`ConfigMap`](https://cloud.google.com/kubernetes-engine/docs/concepts/configmap) objects that contain all of the dashboards and datasource configurations.

The dashboards can be found under [`./dashboards`](./dashboards), while the template for the `ConfigMap`s can be found under [`./templates`](./templates) (templated by [Helm](https://helm.sh/) when creating a new revision of a release).


### Updating panels and dashboards

Given that all of the state lives under [`./dashboards`](./dashboards) and in-place updates are not allowed in the Grafana Web UI, to update a dashboard, copy the JSON configuration and paste it under the corresponding dashboard.

Once a revision gets created, the `ConfigMap` update will be noticed by a [sidecar](https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/) container under the Grafana pod and update the instance to catch up with the update.

