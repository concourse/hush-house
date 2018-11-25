RELEASE_NAME := prod
NAMESPACE := hush-house
CHART_DIR := ./shuttle

all:
	@echo "Usage: install | upgrade | delete"

setup:
	helm init
	helm dependency update $(CHART_DIR)

install: setup
	helm install \
		--namespace $(NAMESPACE) \
		--debug \
		--wait \
		--name $(RELEASE_NAME) \
		$(CHART_DIR)

upgrade: setup
	helm upgrade \
		--namespace $(NAMESPACE) \
		--debug \
		--wait \
		$(RELEASE_NAME) \
		$(CHART_DIR)

delete:
	helm delete \
		--purge \
		$(RELEASE_NAME)
