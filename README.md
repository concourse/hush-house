# HUSH-HOUSE

> A hush house is an enclosed, noise-suppressed facility used for testing aircraft systems,
> including propulsion, mechanics, electronics, pneumatics, and others.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/EM_NELLIS_HUSH_HOUSE_%282786461516%29.jpg/512px-EM_NELLIS_HUSH_HOUSE_%282786461516%29.jpg)

This repository contains the configuration of [hush-house.concourse-ci.org](https://hush-house.concourse-ci.org), [metrics-hush-house.concourse-ci.org](https://metrics-hush-house.concourse-ci.org), and any other K8S deployments using the `hush-house` Kubernetes cluster.


**Table of contents**

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Repository structure](#repository-structure)
- [Dependencies](#dependencies)
- [Gathering access to the cluster](#gathering-access-to-the-cluster)
- [Creating your own deployment](#creating-your-own-deployment)
- [k8s cheat-sheet](#k8s-cheat-sheet)
  - [Contexts](#contexts)
  - [Namespaces](#namespaces)
  - [Nodes](#nodes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Repository structure

```sh
.
├── ci				# Concourse pipelines and tasks designed to keep
│				# the environment continuously up to date.
│
├── deployments			# Directory that contains all deployments that
│   │				# exist in the k8s cluster. Each deployment directory
│   │				# is packaged as a Helm chart and deployment as a
│   │				# Helm release with the corresponding directory name.
│   │
│   ├── Makefile		# Targets to manage the helm releases (to be used by
│   │				# the pipelines and tasks.
│   │
│   ├── hush-house		# A deployment (`hush-house.concourse-ci.org`).
│   │   ├── README.md		# The deployment's description.
│   │   ├── Chart.yaml		# Metadata about the deployment.
│   │   ├── templates		# K8S resouces and notes to be templated from the values
│   │   │			# specified (.values.yaml + values.yaml)
│   │   ├── requirements.yaml	# Versioned dependencies of this chart.
│   │   ├── values.yaml		# Public values.
│   │   └── .values.yaml	# Private values (credentials)
│   │
│   └── metrics			# Antother deployment (`metrics-hush-house.concourse-ci.org`)
│	...
│       └── values.yaml
│ 
├── helm			# Scripts to automate the provisioning of Helm and its
│				# server-side component (tiller)
│
├── Makefile			# TODO
│
└── terraform			# Terraform files for bringing up the K8S cluster and other
    │				# configuring other infrastructure components necessary
    │				# for the deployments (addresses + cloudsql).
    │
    ├── main.tf			# Entrypoint that makes use of modules to set up the IaaS
    │				# resources.
    │
    ├── address			# Module to create addresses ...
    ├── cluster			# Module for creating GKE clusters w/ node pools
    │   └── vpc			# Module for setting up the VPC of the cluster
    └── database		# Module for setting up CloudSQL

```


## Dependencies

- [LastPass CLI (`lpass-cli`)](https://github.com/lastpass/lastpass-cli)
- [Terraform CLI (`terraform`)](https://www.terraform.io/)
- [Helm (`helm`)](https://helm.sh/)
- [Helm diff plugin (`helm diff`)](https://github.com/databus23/helm-diff)
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/)

ps.: if you're creating your own environment based on an existing k8s cluster, you'll probably only need `helm`.


## Gathering acccess to the cluster


0. Install the dependencies

1. Configure access to the Google cloud project

```sh
gcloud config set project cf-concourse-production
gcloud config set compute/zone us-central1-a
gcloud auth login
```


2. Retrieve the k8s credentials for the cluster

```sh
gcloud container clusters get-credentials hush-house
```


3. Initialize the Helm local configuration

```sh
helm init --client-only
```


4. Retrieve the Helm TLS certificates and the CA certificate


```sh
lpass show helm-ca-cert > $(helm home)/ca.pem
lpass show helm-cert > $(helm home)/cert.pem
lpass show helm-key > $(helm home)/key.pem
```


## Creating your own deployment

To create a new deployment of your own, a Chart under `./deployments` needs to be created (given that every deployment corresponds to releasing a custom Chart).

Here's an example of how that can be done:


1. Populate the repository with metadata about the deployment

```sh
# Create a chart directory under `./deployments`
# For instance, for a deployment named `bananas`:
mkdir ./deployments/bananas

# Create a `Chart.yaml` file with some info about it
echo '---
name: bananas
version: 0.0.1
description: a test deployment!
maintainers:
- name: ciro
' > ./deployments/bananas/Chart.yaml
```


2. Add the concourse release candidate as a dependency

```sh
echo '---
dependencies:
- name: concourse
  version: 1338.0.0
  repository: https://raw.githubusercontent.com/concourse/charts/gh-pages/
' > ./deployments/bananas/Chart.yaml
```


3. Create the `values.yaml` file with public configurations

```sh
echo '---
concourse:
  worker:
    replicas: 3
  concourse:
    web:
      prometheus:
        enabled: true
' > ./deployments/bananas/values.yaml
```


4. *(optional)* Create the `.values.yaml` file with the credentials


```sh
echo '---
concourse:
  secrets:
    localUsers: test:something
' > ./deployments/bananas/.values.yaml
```


5. *(if you have credentials)* Populate the `hush-house-main` namespace with your credentials

Having `kubectl` configured with access to `hush-house-main`:

```sh
cd ./deployments && \
	make hush-house-creds-secrets-bananas
```


## k8s cheat-sheet

Here's a quick cheat-sheet that might help you get started with `kubectl` if you've never used it before.


### Contexts

These are the equivalent of Concourse `target`s, storing auth, API endpoint, and namespace information in each of them.

- Get all configured contexts:

```sh
kubectl config get-contexts
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

### Kubernetes for credential management

Just like you can tie Vault or CredHub to your Concourse instances in order to have secrets suport, you can also make use of Kubernetes secret for that, with some specialties:

- Can't make use of `_`  in the names (a limitation from k8s secrets)

For instance, the Secret `something_a` is invalid:

```
metadata.name:
  Invalid value: "something_a":
    a DNS-1123 subdomain must consist of lower case alphanumeric characters, '-' or '.',
    and must start and end with an alphanumeric character (e.g. 'example.com', regex used
    for validation is '[a-z0-9]([-a-z0-9]*[a-z0-9])?(\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*')
```

- Names must not be longer than `63` characters

- for interpolating ((mything)):

```
kubectl create generic mything \
  --from-literal=value=$value \
  --namespace $prefix$team
```

- for interpolating nested structures ((mything.foo)):

```
kubectl create generic mything \
  --from-literal=foo=$foo \
  --namespace $prefix$team
```

- roles necessary for `web` to be able to consume those secrets

TODO

- For k8s there's no "per-pipeline" secret setting

- should we include k8s creds health?

TODO
