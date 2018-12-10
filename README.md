# HUSH-HOUSE

> A hush house is an enclosed, noise-suppressed facility used for testing aircraft systems,
> including propulsion, mechanics, electronics, pneumatics, and others.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/EM_NELLIS_HUSH_HOUSE_%282786461516%29.jpg/512px-EM_NELLIS_HUSH_HOUSE_%282786461516%29.jpg)

This repository contains the configuration of [hush-house.concourse-ci.org](https://hush-house.concourse-ci.org) and [metrics-hush-house.concourse-ci.org](https://metrics-hush-house.concourse-ci.org), an acceptance testing environment deployed on top of k8s.


**Table of contents**

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Repository structure](#repository-structure)
- [Dependencies](#dependencies)
- [Upgrading hush-house (pushing a new release)](#upgrading-hush-house-pushing-a-new-release)
- [Creating your own environment](#creating-your-own-environment)
- [k8s cheat-sheet](#k8s-cheat-sheet)
  - [Contexts](#contexts)
  - [Namespaces](#namespaces)
  - [Nodes](#nodes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Repository structure

```sh
.
├── Makefile 			# Definition of the make targets
│				# to deploy/upgrade hush-house.
│
├── shuttle 			# Chart that unites Concourse
│   │				# and some other useful charts
│   ├── Chart.yaml              # that compose `hush-house`.
│   │
│   ├── charts			# Downloaded chart dependencies
│   │   ├── concourse-...tgz
│   │   ├── grafana-1....tgz
│   │   └── prometheus...tgz
│   │
│   ├── dashboards		# Definition of the dashboards
│   │   └── concourse		# used by `metrics-hush-house`.
│   │       ├── concourse.json
│   │       └── postgres.json
│   │
│   ├── requirements.yaml 	# Description of the dependencies
│   ├── requirements.lock	# (other charts)
│   │
│   ├── templates		# Templated `yaml` files that form
│   │   ├── NOTES.txt           # k8s resources that are used by
│   │   ├── _helpers.tpl        # the deployed components.
│   │   ├── grafana-dashboards-config.yaml
│   │   ├── grafana-datasource-config.yaml
│   │   └── tls-secret.yaml
│   │
│   └── values.yaml		# Default values for a full concourse
│				# deployment and surrounding services
│				# (prometheus+grafana)
│
├── .values.yaml 		# Helm values for `shuttle` that contain
│				# sensitive information (credentials).
│
└── terraform			# Mutates the IAAS to provision static
    ├── backend.tf		# IPs for the load-balancers used for
    ├── gcp.json		# `web` and `grafana`, as well as update
    ├── main.tf			# the DNS entries for the environment.
    └── outputs.tf
```


## Dependencies

Below, a list of all of the dependencies needed to upgrade the `hush-house` environment.

- [LastPass CLI (`lpass-cli`)](https://github.com/lastpass/lastpass-cli)
- [Terraform CLI (`terraform`)](https://www.terraform.io/)
- [Helm (`helm`)](https://helm.sh/)
- [Helm diff plugin (`helm diff`)](https://github.com/databus23/helm-diff)

Note.: if you're creating your own environment based of it and not using the provided Makefile, you'll only need `helm`.


## Upgrading hush-house (pushing a new release)

To update the release of [hush-house.concourse-ci.org](https://hus-house.concourse-ci.org), make sure you have the dependencies list under [#dependencies](#dependencies) met, then run the following commands:

```sh
# Retrieve the necessary credentials from lpass.
make creds

# Update the local filesystem with the dependencies (other
# charts) of the hush-house deployment.
make helm-deps

# Compare the desired state as specified in `./.values.yaml`,
# variables from `terraform` and `./shuttle/values.yaml` against
# the current state in the k8s cluster.
#
# It'll display the differences and then ask for confirmation
# to proceed with the deploy.
make upgrade
```

ps.: all `make` target are described in `make help`.


## Creating your own environment

To create a separate environment of your own, run `helm` with a set of values that satisfy your needs against the `shuffle` chart.

For instance:

```sh
export ENV_NAME=dev

helm upgrade \
	--install \
	--namespace $ENV_NAME \
	--set=concourse.worker.replicas=1 \
	$ENV_NAME
	./shuffle
```

By the end, the execution will tell you how to get the necessary credentials and get the service exposed (or, run `helm status $ENV_NAME` to see those again).


## k8s cheat-sheet

Here's a quick cheat-sheet that might help you get started with `kubectl` if you've never used it before.

### Contexts

These are the equivalent of Concourse `target`s, storing auth, API endpoint, and namespace information in each of them.

- Get the current context:

```sh
kubectl config current-context
```


- Change something in a context (for instance, the `namespace` to a default one):

```sh
kubectl config set-context $context \
	--namespace=$new_default_namespace
```


- Set the context to use:

```sh
kubectl config use-context $context
```


### Namespaces

A virtual segregation between resources in a single cluster.

It's common to have environments associated with namespaces such that their resources get isolated too. In this scenario, you can think of namespaces as BOSH deployments - they're all managed by the same director, but they get their instances and other resources isolated from each other.

The namespace to target is supplied via the `--namespace` flag, or having a default namespace set to the context (see [#contexts](#contexts)).


### Nodes

Similar to `bosh vms`, it's possible to gather the list of instances that compose our cluster.

- Retrieve the list of all registered k8s nodes:

```sh
kubectl get nodes
```

- Describe (get events and extra information of) a particular node:

```sh
kubectl describe node $node_name
```
