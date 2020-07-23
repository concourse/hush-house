# ci-topgun-worker

The `ci-topgun-worker` deployment deploys the worker used to run the `k8s-topgun` test suite.
The test suite can be triggered in a few places:

- The main Concourse pipeline or any of the `release/#.#.x` pipelines
- The `helm-prs...` pipelines

It relies solely on the [Concourse chart](https://github.com/concourse/concourse-chart).

## Deploying

To deploy these workers:

- `kubectl config use-context topgun` to deploy to the `topgun` cluster on GKE
- ~run `make deploy-ci-topgun-worker` from `/deployments/with-creds`.~ **TODO: `make` method doesn't work because of `--tls`**
  - `cd ci-topgun-worker && helm upgrade --install --namespace=ci-topgun-worker --values=./.values.yaml --wait ci-topgun-worker .`

If you want to force a rolling update (recreate all pods), say after updating
secrets, increment the `rollingUpdate` annotation declared in [`values.yaml`].
