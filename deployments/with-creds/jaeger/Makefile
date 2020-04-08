HELM_FLAGS   ?=

creds-jaeger:
	lpass show --notes hush-house-values-jaeger > ./.values.yaml


save-creds-jaeger:
	cat ./.values.yaml | \
		lpass edit \
			--sync=now \
			--non-interactive \
			hush-house-values-jaeger


diff-jaeger: | ensure-creds-file-exists-jaeger deps-jaeger
	helm3 diff upgrade \
		--namespace=jaeger \
		--detailed-exitcode \
		--values=./.values.yaml \
		$(HELM_FLAGS) \
		jaeger \
		.


template-jaeger: | ensure-creds-file-exists-jaeger deps-jaeger
	helm3 template \
	--name=jaeger \
	--values=./.values.yaml \
	$(HELM_FLAGS) \
	.


deploy-jaeger: | ensure-creds-file-exists-jaeger deps-jaeger
	helm3 upgrade \
		--install \
		--namespace=jaeger \
		--timeout=900s \
		--values=./.values.yaml \
		--wait \
		$(HELM_FLAGS) \
		jaeger \
		.


deps-jaeger:
	helm3 dependency update .


ensure-creds-file-exists-jaeger:
	@test -f ./.values.yaml || \
		{ \
			echo "ERROR: jaeger misses credentials"; \
			echo "Make sure 'deployments/jaeger/.values.yaml' exists"; \
			exit 1; \
		}
