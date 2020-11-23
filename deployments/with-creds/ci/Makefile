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
	helm diff upgrade \
		--namespace=ci \
		--detailed-exitcode \
		--values=./.values.yaml \
		$(HELM_FLAGS) \
		ci \
		.


template-ci: | ensure-creds-file-exists-ci deps-ci
	helm template \
		ci \
		--values=./.values.yaml \
		$(HELM_FLAGS) \
		. > .template.yaml


deploy-ci: | template-ci
	kapp deploy \
		--namespace ci \
		--app ci \
		--file .template.yaml \
		--diff-changes \
		$(KAPP_FLAGS)


deps-ci:
	helm dependency update .


ensure-creds-file-exists-ci:
	@test -f ./.values.yaml || \
		{ \
			echo "ERROR: ci misses credentials"; \
			echo "Make sure 'deployments/ci/.values.yaml' exists"; \
			exit 1; \
		}
