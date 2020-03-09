HELM_FLAGS   ?=

creds-ci:
	lpass show --notes hush-house-values-ci > ./.values.yaml


save-creds-ci:
	cat ./.values.yaml | \
		lpass edit \
			--sync=now \
			--non-interactive \
			hush-house-values-ci


diff-ci: | ensure-creds-file-exists-ci deps-ci
	helm3 diff upgrade \
		--namespace=ci \
		--detailed-exitcode \
		--values=./.values.yaml \
		$(HELM_FLAGS) \
		ci \
		.


template-ci: | ensure-creds-file-exists-ci deps-ci
	helm3 template \
	--name=ci \
	--values=./.values.yaml \
	$(HELM_FLAGS) \
	.


deploy-ci: | ensure-creds-file-exists-ci deps-ci
	helm3 upgrade \
		--install \
		--namespace=ci \
		--timeout=900s \
		--values=./.values.yaml \
		--wait \
		$(HELM_FLAGS) \
		ci \
		.


deps-ci:
	helm3 dependency update .


ensure-creds-file-exists-ci:
	@test -f ./.values.yaml || \
		{ \
			echo "ERROR: ci misses credentials"; \
			echo "Make sure 'deployments/ci/.values.yaml' exists"; \
			exit 1; \
		}
