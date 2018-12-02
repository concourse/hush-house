# HUSH-HOUSE

> A hush house is an enclosed, noise-suppressed facility used for testing aircraft systems,
> including propulsion, mechanics, electronics, pneumatics, and others.

![](https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/EM_NELLIS_HUSH_HOUSE_%282786461516%29.jpg/512px-EM_NELLIS_HUSH_HOUSE_%282786461516%29.jpg)

## k8s cheat-sheet

### Contexts

These are the equivalent of Concourse `target`s, storing auth, API endpoint,
and namespace information in each of them.

Get the current context:

	kubectl config current-context


Change something in a context:

	kubectl config set-context $context \
		$something_to_change


Set the context to use:

	kubectl config use-context $context


### Namespaces

A virtual segregation between resources in a single cluster.

The namespace to target is supplied via the `--namespace` flag, or having
a default namespace set to the context:


	kubectl config set-context $context \
		--namespace=$namespace


### Checking the versions

	kubectl version

	ps.: it's fine to diverge 2 minors.


### Nodes

	kubectl get nodes --namespace=$NS
	kubectl describe nodes --namespace=$NS
