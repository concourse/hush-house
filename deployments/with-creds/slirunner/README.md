# slirunner

The `slirunner` deployment is an experiment on having [`slirunner`][slirunner] deployed in a Kubernetes cluster to probe a given Concourse installation (in this case, [`hush-house`][hush-house]).

Once deployed, it continuously runs probes against Concourse, exposing the result of those through [Prometheus][prometheus] metrics. Having a [Kubernetes Service][k8s-service] associated with the deployment, the Prometheus server deployed in the [metrics stack][metrics-stack] then collects those, which are then graphed in the `SLIs` panel in [Grafana][grafana] (also part of the metrics stack), accessible under https://metrics-hush-house.concourse-ci.org.


[slirunner]: https://github.com/cirocosta/slirunner
[hush-house]: https://hush-house.pivotal.io
[prometheus]: https://prometheus.io
[metrics-stack]: https://github.com/concourse/hush-house/blob/master/deployments/with-creds/metrics/README.md
[k8s-service]: https://kubernetes.io/docs/concepts/services-networking/service/
[grafana]: https://grafana.com/
