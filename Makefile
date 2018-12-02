RELEASE_NAME ?= prod
NAMESPACE    ?= hush-house
CHART_DIR    ?= ./shuttle

WEB_LOADBALANCER_IP     = $(shell cd ./terraform && terraform output web-address)
METRICS_LOADBALANCER_IP = $(shell cd ./terraform && terraform output metrics-address)


all:
	@echo "Usage: deps | upgrade | delete"


depsk:
	helm init
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
	@echo -n "Do you want to proceed? " && read ans && [ $$ans == y ]
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
	helm delete \
		--purge \
		$(RELEASE_NAME)
