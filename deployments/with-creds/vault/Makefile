HELM_FLAGS   ?=

creds-vault:
	lpass show --notes hush-house-values-vault > ./.values.yaml


save-creds-vault:
	cat ./.values.yaml | \
		lpass edit \
			--sync=now \
			--non-interactive \
			hush-house-values-vault


diff-vault: | ensure-creds-file-exists-vault deps-vault
	helm diff upgrade \
		--namespace=vault \
		--detailed-exitcode \
		--values=./.values.yaml \
		$(HELM_FLAGS) \
		vault \
		.


template-vault: | ensure-creds-file-exists-vault deps-vault
	helm template \
		--name=vault \
		--values=./.values.yaml \
		$(HELM_FLAGS) \
		.


deploy-vault: | ensure-creds-file-exists-vault deps-vault
	helm upgrade \
		--install \
		--namespace=vault \
		--timeout=900s \
		--values=./.values.yaml \
		--wait \
		$(HELM_FLAGS) \
		vault \
		.

deps-vault:
	grep 'file://' requirements.yaml || \
	helm dependency update .


ensure-creds-file-exists-vault:
	@test -f ./.values.yaml || \
		{ \
			echo "ERROR: vault misses credentials"; \
			echo "Make sure 'deployments/vault/.values.yaml' exists"; \
			exit 1; \
		}
