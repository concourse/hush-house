
# HUSH-HOUSE

> A hush house is an enclosed, noise-suppressed facility used for testing aircraft systems,
> including propulsion, mechanics, electronics, pneumatics, and others.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/EM_NELLIS_HUSH_HOUSE_%282786461516%29.jpg/512px-EM_NELLIS_HUSH_HOUSE_%282786461516%29.jpg)

This repository contains the configuration of [hush-house.concourse-ci.org](https://hush-house.concourse-ci.org) and [metrics-hush-house.concourse-ci.org](https://metrics-hush-house.concourse-ci.org), an acceptance testing environment deployed on top of k8s.

**Table of contents**

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Dependencies](#dependencies)
- [Deploying hush-house](#deploying-hush-house)
- [k8s cheat-sheet](#k8s-cheat-sheet)
  - [Contexts](#contexts)
  - [Namespaces](#namespaces)
  - [Checking the versions](#checking-the-versions)
  - [Nodes](#nodes)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Dependencies

- [LastPass CLI (`lpass-cli`)](https://github.com/lastpass/lastpass-cli)
- [Terraform CLI (`terraform`)](https://www.terraform.io/)
- [Helm (`helm`)](https://helm.sh/)
- [Helm diff plugin (`helm diff`)](https://github.com/databus23/helm-diff)


## Deploying hush-house

To update the release of [hush-house.concourse-ci.org](https://hus-house.concourse-ci.org), make sure you have the dependencies list under [#dependencies](#dependencies) met, then run the following commands:

```sh
# Retrieves the necessary credentials from lpass.
make creds

# Updates the local filesystem with the dependencies (other
# charts) of the hush-house deployment.
make helm-deps

# Compares the desired state as specified in `./.values.yaml`,
# variables from `terraform` and `./shuttle/values.yaml` against
# the current state in the k8s cluster.
#
# It'll display the differences and then ask for confirmation
# to proceed with the deploy.
make upgrade
```

ps.: all `make` target are described in `make help`.


## k8s cheat-sheet

Here's a quick cheat-sheet that might help you get started with `kubectl` if you've never used it before.

### Contexts

These are the equivalent of Concourse `target`s, storing auth, API endpoint,
and namespace information in each of them.

- Get the current context:

	kubectl config current-context


- Change something in a context (for instance, the `namespace` to a default one):

	kubectl config set-context $context \
		--namespace=$new_default_namespace


- Set the context to use:

	kubectl config use-context $context


### Namespaces

A virtual segregation between resources in a single cluster.

The namespace to target is supplied via the `--namespace` flag, or having
a default namespace set to the context.


### Checking the versions

	kubectl version

*ps.: it's fine to diverge 2 minors.*


### Nodes


- Retrieve the list of all registered k8s nodes:

	kubectl get nodes


- Describe a particular node:

	kubectl describe node $node_name
