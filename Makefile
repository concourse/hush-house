RELEASE_NAME ?= hush-house
NAMESPACE    ?= hush-house
CHART_DIR    ?= ./shuttle
HELM_FLAGS   ?=


define HELP
USAGE
	make (creds|delete|diff|helm-deps|help|k8s-secret|template|upgrade)

COMMANDS
	creds		Retrieves the necessary credentials from lpass in
				order to have all the keys necessary for interacting
				with the kubernetes cluster and providing the proper
				keys to the deployment specs.


	delete		Deletes the hush-house helm release.
				ATTENTION: This command is **DESTRUCTIVE** and it
				will take the whole deployment down.


	diff		Checks if there are any differences between the current
				state in the cluster and the desired state as represented
				by the local yaml files and chart version.


	helm-deps	Updates the local view of the helm dependencies that
				compose the `shuttle` chart.


	k8s-secret	Updates the secret that contains the `.values.yml` file
				in the kubernetes secret store so that the pipeline
				in this repository can update the state of hush-house
				by using k8s as a credential management.


	template	Displays the final version of all of the k8s resources
				that get sent to Tiller before being applie to k8s.

				This allows you to verify if the k8s objects match your
				expectations when debugging.


	upgrade		Upgrades the hush-house release with the new definitions
				as specified by the `shuttle` chart and the values supplied
				to it.

				It WILL NOT display a diff before applying the changes.
				To do that, use `make diff`.

endef


all: help


creds:
	lpass sync
	lpass show hush-house-helm-values --notes > ./.values.yml
	lpass show hush-house-gcp-key --notes > ./terraform/gcp.json


k8s-secret:
	kubectl create secret generic values-b64 \
		--namespace=$(RELEASE_NAME)-main \
		--from-literal="value=$(shell cat ./.values.yml | base64)"


helm-deps:
	helm dependency update $(CHART_DIR)


template:
	helm template \
	  --values=./.values.yml \
	  $(HELM_FLAGS) \
	  $(CHART_DIR)


diff:
	helm diff upgrade \
		--namespace=$(NAMESPACE) \
		--detailed-exitcode \
		--values=./.values.yml \
		$(HELM_FLAGS) \
		$(RELEASE_NAME) \
		$(CHART_DIR)


upgrade:
	@echo -n "You're about to UPGRADE."
	@echo -n "This action might destroy and/or create resources."
	@echo -n "Do you want to proceed (y/n)? " && read ans && [ $$ans == y ]
	helm upgrade \
		--install \
		--namespace=$(NAMESPACE) \
		--values=./.values.yml \
		--timeout=600 \
		--wait \
		$(HELM_FLAGS) \
		$(RELEASE_NAME) \
		$(CHART_DIR)


delete:
	@echo -n "Do you want to proceed? (y/n) " && read ans && [ $$ans == y ]
	@echo -n "Really? (y/n) " && read ans && [ $$ans == y ]
	helm delete \
		--purge \
		$(RELEASE_NAME)


export HELP
help:
	@echo "$$HELP"
