RELEASE_NAME := prod
NAMESPACE    := hush-house
CHART_DIR    := ./shuttle

all:
	@echo "Usage: install | upgrade | delete"


terraform:
	cd ./terraform && \
		terraform init && \
		terraform apply


setup:
	helm init
	helm dependency update $(CHART_DIR)


LOADBALANCER_IP=$(shell cd ./terraform && terraform output instance_ip)
install: setup
	helm install \
		--namespace $(NAMESPACE) \
		--set=concourse.web.service.loadBalancerIP=$(LOADBALANCER_IP) \
		--debug \
		--wait \
		--name $(RELEASE_NAME) \
		$(CHART_DIR)


LOADBALANCER_IP=$(shell cd ./terraform && terraform output instance_ip)
upgrade: setup
	helm upgrade \
		--namespace $(NAMESPACE) \
		--set=concourse.web.service.loadBalancerIP=$(LOADBALANCER_IP) \
		--debug \
		--wait \
		$(RELEASE_NAME) \
		$(CHART_DIR)


delete:
	helm delete \
		--purge \
		$(RELEASE_NAME)


sync-grafana-dashboards:
	grafana-sync \
		--directory=./shuttle/dashboards/concourse \
		--username=admin \
		--password=$(GRAFANA_PASSWORD) \
		pull

