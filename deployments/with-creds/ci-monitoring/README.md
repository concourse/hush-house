# ci-monitoring

The `ci-monitoring` deployment deploys the worker that assign to team `monitoring-hush-house`
for running hush-house.pivotal.io monitoring loads.

It relies solely on the [Concourse chart](https://github.com/concourse/concourse-chart).

## Deploying

To deploy these workers, run `make deploy-ci-monitoring` from `/deployments/with-creds`.

If you want to force a rolling update (recreate all pods), say after updating
secrets, increment the `rollingUpdate` annotation declared in [`values.yaml`].

[`values.yaml`]: ./values.yaml


## Debugging

Metrics, logs, and debug endpoints work the same as for the [`ci`] deployment.
Check that deployment's README to know more.

[`ci`]: ../ci
