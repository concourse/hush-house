# HUSH-HOUSE

<br />

<img align="left" width="296" height="222" src="https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/EM_NELLIS_HUSH_HOUSE_%282786461516%29.jpg/512px-EM_NELLIS_HUSH_HOUSE_%282786461516%29.jpg">

<br />

> A **hush house** is an enclosed, noise-suppressed facility used for testing aircraft systems,
> including propulsion, mechanics, electronics, pneumatics, and others.


<br />


This repository contains the configuration of [hush-house.pivotal.io](https://hush-house.pivotal.io), [metrics-hush-house.concourse-ci.org](https://metrics-hush-house.concourse-ci.org), and any other [Kubernetes (K8S)](https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/) deployments using the `hush-house` Kubernetes cluster available in the shared Concourse [Google Cloud](https://cloud.google.com/) account.

<br />


**Table of contents**

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Repository structure](#repository-structure)
- [Dependencies](#dependencies)
- [Gathering acccess to the cluster](#gathering-acccess-to-the-cluster)
- [IaaS](#iaas)
- [Deployments](#deployments)
  - [Creating a new deployment](#creating-a-new-deployment)
  - [Without any credentials setup](#without-any-credentials-setup)
  - [With credentials](#with-credentials)
  - [Visualizing metrics from your deployment](#visualizing-metrics-from-your-deployment)
- [SSHing into the Kubernetes node VM](#sshing-into-the-kubernetes-node-vm)
- [k8s cheat-sheet](#k8s-cheat-sheet)
  - [Contexts](#contexts)
  - [Namespaces](#namespaces)
  - [Nodes](#nodes)
  - [Kubernetes for credential management](#kubernetes-for-credential-management)
- [Bootstrapping the cluster](#bootstrapping-the-cluster)
  - [Getting the GCP credentials](#getting-the-gcp-credentials)
  - [Applying the Terraform](#applying-the-terraform)
  - [Creating the base Kubernetes objects](#creating-the-base-kubernetes-objects)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Repository structure

```sh
.
├── ci				# Concourse pipelines and tasks designed to keep
│				# the environment continuously up to date.
│
│
├── deployments 		# Where you can find all deployments that get
│   │				# continuously deployed by `hush-house` when changes
│   │				# to configurations in this repository are made.
│   │
│   │
│   ├── with-creds		# Deployments that require credentials that do not exist
│   │   │			# in this repository (as they're not public)
│   │   │
│   │   ├── Makefile		# Scripting related to the deployments
│   │   │
│   │   ├── hush-house  # The web nodes of the `hush-house` Concourse deployment
│   │   ├── worker		  # The deployment of the kgeneric pool of workers that connect to `hush-house`
│   │   └── metrics		  # The `metrics` deployment
│   │
│   │
│   │
│   └── without-creds		# Deployments that require NO credentials, i.e., that rely
│       │			# solely on public values from this repository.
│       │
│       ├── Makefile		# Scripting related to the deployments.
│       │
│       └── bananas		# Fully functioning example deployment.
│
│ 
├── helm			# Scripts to automate the provisioning of Helm and its
│				# server-side component (tiller)
│
│
├── Makefile			# General scripting for getting access to the cluster and
│				# setting up the pipelines.
│
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
  - `brew install lastpass-cli`
- [Terraform CLI (`terraform`)](https://www.terraform.io/)
  - `brew install terraform`
- [Helm (`helm`)](https://helm.sh/)
  - `brew install kubernetes-cli`
  - `brew install kubernetes-helm`
- [Helm diff plugin (`helm diff`)](https://github.com/databus23/helm-diff)
  - `helm plugin install https://github.com/databus23/helm-diff --version master`
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/)
  - `brew cask install google-cloud-sdk`

*ps.: if you're creating your own environment based on an existing k8s cluster, you'll probably only need `helm`.*


## Gathering acccess to the cluster

0. Install the [dependencies](#dependencies)

1. Configure access to the Google Cloud project

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

Note.: this is only needed if you've never initialized `helm` locally.

```sh
helm init --client-only
```


4. Retrieve the Helm TLS certificates and the CA certificate


```sh
# fetch the creds to lpass
make helm-creds

# copy the credentials to $HELM_HOME
make helm-set-client-creds
```


## IaaS

As `hush-house` is a complete environment for deploying Concourse and any other Helm charts, it requires few infrastructure pieces to be in place.

All of that is provisioned using [`terraform`](https://terraform.io), having its configuration under the [`./terraform` directory](./terraform).

**Make sure you DON'T change the IaaS parameters in the Google Cloud Console** - modifications *MUST* be made through `terraform`.



## Deployments

In the `hush-house` cluster, there are currently a few Helm charts deployments running.

As mentioned in the [repository structure section](#repository-structure), these all live under [`./deployments`](./deployments).

Check the [`deployments` README](./deployments/README.md) to know more about them.


### Creating a new deployment

To create a new deployment of your own, a Chart under `./deployments/(with|without)-crekds` needs to be created (given that every deployment corresponds to releasing a custom Chart).

There are two possible types of deployments we can create:

1. without any credentials setup, and
2. with credentials.




### Without any credentials setup

*tl;dr: copy the `./deployments/without-creds/bananas` directory and change `bananas` to the name of the deployment you want.*

0. Create a directory under `./deployments/without-creds`, and get there:

```sh
mkdir ./deployments/without-creds/bananas
cd ./deployments/without-creds/bananas
```


1. Populate the repository with the required files for a Helm Chart, as well as metadata about itself (`Chart.yaml`):

```sh
# Create the required files
touch ./{Chart.yaml,requirements.yaml,values.yaml}


# Populate `Chart.yaml` file with some info about it
echo '---
name: bananas
version: 0.0.1
description: a test deployment!
maintainers:
- name: ciro
' > ./Chart.yaml
```


2. Add the concourse release candidate as a dependency

```sh
echo '---
dependencies:
- name: concourse
  version: 0.0.15
  repository: https://raw.githubusercontent.com/concourse/charts/gh-pages/
' > ./deployments/bananas/requirements.yaml
```

ps.: the version can be retrieved from [concourse/charts](https://github.com/concourse/charts/tree/gh-pages).

pps.: the upstream version of the Chart could be used too! See [`helm/charts`](https://github.com/helm/charts) for instructions.


With that set, `hush-house` is ready to have the deployment going.

You can either trigger the deployment from your own machine if you have Helm already set up, or make a PR to `hush-house` so that the pipeline does it all for you.

Once the process is completed, you should be able to see your resources under the deployment namespace:


```
kubectl  get pods --namespace=bananas
NAME                                  READY   STATUS    RESTARTS   AGE
bananas-postgresql-7f779c5c96-c8f4v   1/1     Running   0          2m
bananas-web-78db545cc9-xrzd9          1/1     Running   1          2m
bananas-worker-78f6cddccb-brvm9       1/1     Running   0          2m
bananas-worker-78f6cddccb-qd6zn       1/1     Running   0          2m
bananas-worker-78f6cddccb-xv7p5       1/1     Running   0          2m
```


### With credentials

A deployment that requires credentials that can't be publicly shared involve all of the steps above, including some few more. Once those steps were finish, proceed with the following  :


1. Create the `values.yaml` file with public configurations

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


2. Populate the `.values.yaml` file with credentials


```sh
echo '---
concourse:
  secrets:
    localUsers: test:something
' > ./deployments/bananas/.values.yaml
```

*ps.: this can be left blank*


3. Populate the `hush-house-main` namespace with your credentials

Having `kubectl` configured (see [*gathering access to the cluster*](#gathering-access-to-the-cluster)) with access to `hush-house-main`, create the secret using the `hush-house-creds-secrets-$DEPLOYMENT` target from [`./deployments/with-creds/Makefile`](./deployments/with-creds/Makefile):

```sh
# go back to `./deployments/with-creds`
cd ..
make hush-house-creds-secrets-bananas
```


### Visualizing metrics from your deployment

When using the Concourse Helm chart, metrics get scrapped and graphed by default under https://metrics-hush-house.concourse-ci.org if [Prometheus](https://prometheus.io) integration is enabled.

To do so, make sure you have `concourse.web.prometheus.enabled` set to `true` and the `prometheus.io` annotations added to `concourse.web`:

```yaml
concourse:
  web:
    annotations:
      prometheus.io/scrape: "true"
      prometheus.io/port: "9391"
  concourse:
    web:
      prometheus:
        enabled: true
```

With that set, head to the `Concourse` dashboard under the metrics address provided above and change the `Namespace` dropdown to the one corresponding to the name of your deployment.


## SSHing into the Kubernetes node VM

As the worker nodes created by worker pools declared in [the main Terraform file](./terraform/main.tf) are just regular GCP instances, these can be accessed using the regular ways of accessing VMs through `gcloud`.


```sh
# The name of the instance can be retrieved from the
# command that lists nodes connected to the k8s cluster:
# - `kubectl get nodes`.
NODE_NAME="gke-hush-house-test-workers-1-46b1d860-65mf"


# Use `gcloud` to facilitate the process of getting the
# right credentials set up for SSHing into the machine.
#
# ps.: you must have `gcloud` credentials set up before
#      proceeding - check out the section `Gathering acccess to the cluster`
#      in this README file.
gcloud compute \
	ssh \
	--zone us-central1-a \
	$NODE_NAME
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


## Bootstrapping the cluster

Creating the `hush-house` cluster on GKE from the ground up requires:

1. having GCP credentials,
2. applying the Terraform definition under `./terraform`, then
3. creating few objects in the Kubernetes cluster.

Below you find instructions to how to do those steps.

### Getting the GCP credentials

Access to the GCP credentials for `hush-house` can be granted through a GCP JSON key stored in LastPass.

The `Makefile` at the root of this repository contains a target for retrieving that key and placing it at the right place:

```sh
make creds
```

### Applying the Terraform

With the credential obtained, we can follow up creating the underlying resources in the IaaS (GCP), using the defitnions under the `./terraform` directory.

```sh
cd ./terraform
terraform apply
```


### Creating the base Kubernetes objects

A fully working `hush-house` Kubernetes clusters requires few components: a Tiller deployment (the server-side compoennt of Helm), and a custom `StorageClass` (so we can create PersistentVolumeClaims based of SSD storage).


To configure Tiller, first get the Helm certificates and keys from LastPass and then run the script that bootstraps it.

*Note.: the script is meant to be run with the current working directory pointing to `cluster-bootstrap`.*

```sh
make helm-creds
cd ./cluster-bootstrap
./bootstrap-tiller.sh
```

To finish the bootstrapping, we now need to create the StorageClass. From the root of this repository, run the following:

```sh
cd ./cluster-bootstrap/storage
./ssd-storage-class.sh
```

