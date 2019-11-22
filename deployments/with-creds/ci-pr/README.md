# ci-pr

The `ci-pr` deployment deploys the workers used to run untrusted workloads that
when someeone pushes a PR to `concourse/concourse`.

It relies solely on the [Concourse chart](https://github.com/concourse/concourse-chart).


## Restrictions

Being a deployment that's supposed to accept untrusted workloads (from community
PRs), network constraints are set to this deployment - see [`NetworkPolicy`].

[`NetworkPolicy`]: ./templates/network-policy.yaml


## Deploying

To deploy these workers, run `make deploy-ci-pr` from `/deployments/with-creds`.

If you want to force a rolling update (recreate all pods), say after updating
secrets, increment the `rollingUpdate` annotation declared in [`values.yaml`].

[`values.yaml`]: ./values.yaml


## Debugging

Metrics, logs, and debug endpoints work the same as for the [`ci`] deployment.
Check that deployment's README to know more.

[`ci`]: ../ci
