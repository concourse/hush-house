# Deployments

Here's where you can find all of the deployments that are picked up by `hush-house` to deploy in the `hush-house` cluster using the [`deploy` pipeline](https://hush-house.pivotal.io/teams/main/pipelines/deploy).

Each deployment directory is meant to be a [Helm Chart](https://github.com/helm/helm/blob/master/docs/charts.md), supposed to be continuously deployed in the form of releases.

For more information about each deployment, jump to the corresponding directory's README:

- Concourse installation
  - [hush-house](./with-creds/hush-house/README.md)
  - [worker](./with-creds/worker/README.md)

- Infrastructure
  - [metrics](./with-creds/metrics/README.md)
  - [sysctl](./without-creds/worker/README.md)

- Samples
  - [bananas](./without-creds/bananas/README.md)


## Directory structure

There are two types of deployments that can be performed through `hush-house`: with and without credentials.

Each deployment type gets its own directory, thus, we have the `with-creds` and `without-creds` directories.

```
.
├── with-creds			# Directory for deployments that require
│   │				# extra credentials
│   │ 
│   ├── Makefile			# Scripting for managing deployments that
│   │					# require credentials.
│   │ 
│   ├── hush-house			# `hush-house` itself - a deployment that require
│   │   │				# a bunch of creds.
│   │   │
│   │   ├── Chart.yaml				# metadata about the chart
│   │   ├── README.md				# information about it
│   │   ├── requirements.lock
│   │   ├── requirements.yaml			# where `hush-house` dependencies get set
│   │   ├── templates				# extra files to template when creating the chart
│   │   │   ├── NOTES.txt			# notes for whoever `helm status` the chart
│   │   │   ├── _helpers.tpl
│   │   │   └── team-authorized-keys-configmap.yaml	# team-specific public keys to authorize
│   │   │
│   │   └── values.yaml			# public values set for this deployment
│   │
│   │
│   └── metrics				# another chart that requires creds ...
│       ├── Chart.yaml
│       ├── ...
│       └── values.yaml
│
│
└── without-creds		# Directory for deployments that require NO
    │ 				# extra credentials.
    │ 
    ├── Makefile			# Scripting for managing the deployments.
    │ 
    └── bananas				# An example deployment without any credentials.
        ├── Chart.yaml
        ├── README.md
        ├── requirements.lock
        ├── requirements.yaml
        └── values.yaml
```


### Without credentials

For deployments that do not require any sensitive information, this type of deployment is the easiest to set up - drop your chart under `./deployments/without-creds` and your good to go - `hush-house` will pick it up and deploy it for you.

For instance, check out `./deployments/without-creds/bananas` for an example of a Concourse chart that has no credentials set.


### With credentials

Such deployment type is intended for those that require having some form of secrets set in a `.values.yaml` file containing information that can't be shown in the public repository.

When `hush-house` goes for performing your deployment, it first gathers the secret `.values.yaml` file from a Kubernetes secret under `hush-house-main` named `((${deployment}-values-b64))`, puts that as a `.values.yaml` file under your deployment directory and then goes on with `helm upgrade`.

For that reason, this directory requires a secret to be set in the k8s cluster in the right namespace prior to the `hush-house` deployment.












