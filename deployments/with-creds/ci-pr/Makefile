HELM_FLAGS   ?=

creds-ci-pr:
	lpass show --notes hush-house-values-ci-pr > ./.values.yaml


save-creds-ci-pr:
	cat ./.values.yaml | \
		lpass edit \
			--sync=now \
			--non-interactive \
			hush-house-values-ci-pr


diff-ci-pr: | ensure-creds-file-exists-ci-pr deps-ci-pr
	helm3 diff upgrade \
		--namespace=ci-pr \
		--detailed-exitcode \
		--values=./.values.yaml \
		$(HELM_FLAGS) \
		ci-pr \
		.


template-ci-pr: | ensure-creds-file-exists-ci-pr deps-ci-pr
	helm3 template \
		ci-pr \
		--values=./.values.yaml \
		$(HELM_FLAGS) \
		. > .template.yaml


deploy-ci-pr: | template-ci-pr
	kapp deploy \
		--namespace ci-pr \
		--app ci-pr \
		--file .template.yaml \
		--diff-changes \
		$(KAPP_FLAGS)


deps-ci-pr:
	helm3 dependency update .


ensure-creds-file-exists-ci-pr:
	@test -f ./.values.yaml || \
		{ \
			echo "ERROR: ci-pr misses credentials"; \
			echo "Make sure 'deployments/ci-pr/.values.yaml' exists"; \
			exit 1; \
		}
