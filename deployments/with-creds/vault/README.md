# Setup

1. ~Clone [vault-helm](https://github.com/hashicorp/vault-helm) into charts/vault-helm and checkout the version referenced in `requirements.yaml`~
1. We have a forked version of [vault-helm](https://github.com/concourse/vault-helm). Which has something special for the postgres backend. Please keep using this version until it gets merged back to `vault-helm` chart.
1. How to deploy `vault`
    1. `git clone https://github.com/concourse/vault-helm` to the `charts` (hush-house/deployments/with-creds/vault/charts) directory.
    1. `make creds-vault`
    1. `make deploy-vault`. If you get the error `app-name has no deployed releases`, delete the deployment with the command `helm delete --purge vault --tls`, then try again.
1. Verify
    1. You should be able to login in to the container with the command `kubectl exec -it -n vault vault-0 /bin/sh`
    1. `export VAULT_SKIP_VERIFY=true`
    1. `export VAULT_TOKEN=<vault initial root token from lastpass>`
    1. `vault status`.
        ```
        Key                      Value
        ---                      -----
        Recovery Seal Type       shamir
        Initialized              true
        Sealed                   false
        Total Recovery Shares    5
        Threshold                3
        Version                  1.2.4
        Cluster Name             vault-cluster-1c5d79f5
        Cluster ID               2d6904b1-04ff-xxxx-xxxx-01fc92f15795
        HA Enabled               false
        ```
    1. `vault list /concourse/main`. You should see those credentials.

