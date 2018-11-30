RELEASE_NAME := prod
NAMESPACE    := hush-house
CHART_DIR    := ./shuttle


all:
	@echo "Usage: upgrade | delete"


setup:
	helm init
	cd ../charts/stable/concourse && helm dependency update .
	helm dependency update $(CHART_DIR)


WEB_LOADBALANCER_IP=$(shell cd ./terraform && terraform output web-address)
METRICS_LOADBALANCER_IP=$(shell cd ./terraform && terraform output metrics-address)
upgrade: setup
	helm upgrade $(HELM_FLAGS) \
		--install \
		--namespace=$(NAMESPACE) \
		--recreate-pods \
		--set=concourse.web.service.loadBalancerIP=$(WEB_LOADBALANCER_IP) \
		--set=grafana.service.loadBalancerIP=$(METRICS_LOADBALANCER_IP) \
		--values=./.values.yml \
		--wait \
		$(RELEASE_NAME) \
		$(CHART_DIR)


delete:
	helm delete \
		--purge \
		$(RELEASE_NAME)
