# hush-house

The `hush-house` deployment is responsible for the Concourse environment running under the publicly accessible URL https://hush-house.concourse-ci.org.

It relies solely on the release-candidate version of the Concourse chart ([concourse/charts](https://github.com/concourse/charts/tree/gh-pages)), and Kubernetes (k8s) objects (`ConfigMap`s) created by Helm templating files under [`./templates`](./templates).


<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Web](#web)
- [Workers](#workers)
  - [Adding external workers](#adding-external-workers)
- [Metrics](#metrics)
- [Logs](#logs)
- [Accessing debug endpoints](#accessing-debug-endpoints)
  - [Generating goroutine dumps to be consumed by swirly](#generating-goroutine-dumps-to-be-consumed-by-swirly)
  - [Retrieving and visualizing profiles](#retrieving-and-visualizing-profiles)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Web

The ATCs in this deployment have all of their state in [CloudSQL](https://cloud.google.com/sql/docs/) instead of a self-hosted Postgres instance managed by k8s.

Credentials for it can be found under `./.values.yaml`, which can be obtained by running `make creds-hush-house` from the [deployments](../deployments) directory (it fetches the credentials from the shared Concourse [LastPass](https://www.lastpass.com/) account).

See [`./values.yaml`](./values.yaml) for configuration details.

See the [Terraform directory](/terraform) for information about the instantiation of CloudSQL on GCP.



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


## Metrics

Metrics are gathered through a stack independetly deployed called `metrics` (see [../metrics](../metrics)) which can be accessed through [metrics-hush-house.concourse-ci.org](https://metrics-hush-house.concourse-ci.org/dashboards).

The Concourse-specific panels can be found under the dashboard named `Concourse`, with the Namespace variable set to `hush-house`.

Panels related to the Go runtime can be found under the dashboard named `Go`, which also supports namespace filtering - set it to `hush-house` to see metrics that pertain the `hush-house` deployment.


## Logs

Logs can be retrieved either directly from `kubectl`:

```
# Retrieve a pod to get logs from
POD=$(kubectl get pods --namespace=hush-house -o name | grep 'web' | head -n 1)

# Gather the logs
kubectl logs
	--namespace=hush-house \
	$POD
```

Or through [`stackdriver`](https://cloud.google.com/stackdriver/):

1. Go to [Stackdriver Logs Viewer](https://console.cloud.google.com/logs/viewer); then

2. Filter by `GKE Container`.


## Accessing debug endpoints

To access the debug endpoint ([pprof](https://golang.org/pkg/net/http/pprof/)) of a particular container of a pod, create a local port forwarding session against one of the pods (not the service):

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

ps.: workers have debug endpoints too.


### Generating goroutine dumps to be consumed by swirly

To generate a goroutine dump that is compatible with [swirly](https://github.com/vito/swirly):

1. Have the debug endpoint forwarded to 127.0.0.1

See [accessing debug endpoints](#accessing-debug-endpoints)

2. Retrieve the goroutine dump

```sh
curl -SL http://localhost:8079/debug/pprof/goroutine?debug=2 > /tmp/dump
```

3. Put the dump in the [`swirly` webpage](https://vito.github.io/swirly).


### Retrieving and visualizing profiles

0. Install the dependencies

The default visualization of the profiles rely on few tools from the [`graphviz`](https://www.graphviz.org/) suite.

1. Have the debug endpoint forwarded to 127.0.0.1;

2. Capture a profile letting the Go runtime do it for 30 seconds

```sh
# This request will block for 30seconds before retrieving the profile data.
curl -SL \
	-o /tmp/profile \
	'http://127.0.0.1:8079/debug/pprof/profile?seconds=30'

# Opens
go tool pprof -http=:8080 /tmp/profile.
```

3. Access the profile through the web page available at [`127.0.0.1:8080`](http://127.0.0.1:8080) (your default browser should open automatically).

