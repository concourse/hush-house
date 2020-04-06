HELM_FLAGS   ?=

diff-jaeger: | deps-jaeger
	helm3 diff upgrade \
		--namespace=jaeger \
		--detailed-exitcode \
		$(HELM_FLAGS) \
		jaeger \
		.


template-jaeger: | deps-jaeger
	helm3 template \
	--name=jaeger \
	$(HELM_FLAGS) \
	.


deploy-jaeger: | deps-jaeger
	helm3 upgrade \
		--install \
		--namespace=jaeger \
		--timeout=900s \
		--wait \
		$(HELM_FLAGS) \
		jaeger \
		.


deps-jaeger:
	helm3 dependency update .
