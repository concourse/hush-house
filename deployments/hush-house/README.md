# hush-house

The `hush-house` deployment is responsible for the Concourse environment running under the publicly accessible URL https://hush-house.concourse-ci.org.

It relies solely on the release-candidate version of the Concourse chart - [concourse/charts](https://github.com/concourse/charts/tree/gh-pages), and Kubernetes objects (`ConfigMap`s) created by Helm templating files under [`./templates`](./templates).

## Web

The ATCs in this deployment have all of their state in CloudSQL instead of a Postgres instance managed by k8s.

Credentials for it can be found under `./.values.yaml`, which can be obtained by running `make creds-hush-house` from the [deployments](../deployments) directory (it fetches the credentials from the shared Concourse [LastPass](https://www.lastpass.com/) account).

See [`./values.yaml`](./values.yaml) for configuration details.

See the [Terraform directory](/terraform) for information about the instantiation of CloudSQL on GCP.


### Accessing web containers debug endpoints (pprof)

To access the debug endpoint of a particular container of a pod, create a local port forwarding session against one of the pods (not the service):

```sh
# Retrieve the name of a web pod
POD=$(kubectl get pods --namespace=hush-house -o name | grep 'web' | head -n 1)

# Create the port-forwarding session
kubectl port-forward \
	--namespace=hush-house \
	$POD \
	8079:8079
```

Now, access it via your loopback address on the right port: http://127.0.0.1:8079


## Workers

The workers managed by this deployment are ephemeral by nature and must be used for tasks that are suitable for workloads that can be interrupted.

For workloads that don't fit the description above, external workers need to be plugged in (see [Adding external workers](#adding-external-workers)).


### Adding external workers

External workers can be authorized by having the public side of their SSH keys to the web instances.

To do so, two steps need to be followed:

1. Add the public key to the [`team-authorized-keys` directory](./team-authorized-keys) in a file named `$TEAM_NAME.pub`. If the file already exists, add the key to the end of the file (in a new line).

```sh
# Assuming you're using MacOS and the key is on the
# clipboard, append to the file (it'll create a new
# file if it doesn't exist).
pbpaste >> ./team-authorized-keys/myteam.pub
```

2. (if there are no existing keys for the team already) Update [the public `values.yaml`](./values.yaml)'s file section regarding `teamAuthorizedKeys`, adding to the field the name of the team followed by a `:` and the location of the file in the instance.

For instance, assuming that we want to add a key for the team `myteam` but previously there was only a key reference for `main`:

```sh
# ...
      tsa:
        teamAuthorizedKeys: main:/team-authorized-keys/main.pub
```

You can add a reference to the new key as follows:


```sh
# ...
      tsa:
        teamAuthorizedKeys: main:/team-authorized-keys/main.pub,myteam:/team-authorized-keys/myteam.pub
```

*(yes, this will get better soon)*


### Accessing worker containers debug endpoints (pprof)

Just like in web, but for worker pods - see [Accessing web containers debug endpoints](#accessing-web-containers-debug-endpoints).
