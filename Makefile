RELEASE_NAME ?= prod
NAMESPACE    ?= hush-house
CHART_DIR    ?= ./shuttle

WEB_LOADBALANCER_IP     = $(shell cd ./terraform && terraform output web-address)
METRICS_LOADBALANCER_IP = $(shell cd ./terraform && terraform output metrics-address)


define HELP
USAGE
	make (creds|helm-deps|upgrade|delete)

COMMANDS
	creds		Retrieves the necessary credentials from lpass in
				order to have all the keys necessary for interacting
				with the kubernetes cluster and providing the proper
				keys to the deployment specs.

	helm-deps	Updates the local view of the helm dependencies that
				compose the `shuttle` chart.

	upgrade		Upgrades the hush-house release with the new definitions
				as specified by the `shuttle` chart and the values supplied
				to it.

	delete		Deletes the hush-house helm release.
				ATTENTION: This command is **DESTRUCTIVE** and it
				will take the whole deployment down.
endef


all: help


creds:
	lpass sync
	lpass show hush-house-helm-values --notes > ./.values.yml
	lpass show hush-house-gcp-key --notes > ./terraform/gcp.json


helm-deps:
	cd ../charts/stable/concourse && helm dependency update .
	helm dependency update $(CHART_DIR)


template:
	helm template \
		--set=concourse.web.service.loadBalancerIP=$(WEB_LOADBALANCER_IP) \
		--set=grafana.service.loadBalancerIP=$(METRICS_LOADBALANCER_IP) \
		--values=./.values.yml \
		$(CHART_DIR)


upgrade:
	helm diff upgrade $(HELM_FLAGS) \
		--namespace=$(NAMESPACE) \
		--set=concourse.web.service.loadBalancerIP=$(WEB_LOADBALANCER_IP) \
		--set=grafana.service.loadBalancerIP=$(METRICS_LOADBALANCER_IP) \
		--values=./.values.yml \
		$(RELEASE_NAME) \
		$(CHART_DIR)
	@echo -n "Do you want to proceed (y/n)? " && read ans && [ $$ans == y ]
	helm upgrade $(HELM_FLAGS) \
		--install \
		--namespace=$(NAMESPACE) \
		--set=concourse.web.service.loadBalancerIP=$(WEB_LOADBALANCER_IP) \
		--set=grafana.service.loadBalancerIP=$(METRICS_LOADBALANCER_IP) \
		--values=./.values.yml \
		--wait \
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
