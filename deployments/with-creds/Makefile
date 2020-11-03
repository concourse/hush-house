HELM_FLAGS   ?=

%-ci:
	cd ci && make $*-ci

%-ci-pr:
	cd ci-pr && make $*-ci-pr

%-jaeger:
	cd jaeger && make $*-jaeger


creds-%:
	cd ./$* && \
		lpass show --notes hush-house-values-$* > ./.values.yaml


save-creds-%:
	cd ./$* && \
		cat ./.values.yaml | \
			lpass edit \
				--sync=now \
				--non-interactive \
				hush-house-values-$*


diff-%: | ensure-creds-file-exists-% deps-%
	cd ./$* && \
		helm diff upgrade \
			--tls \
			--namespace=$* \
			--detailed-exitcode \
			--values=./.values.yaml \
			$(HELM_FLAGS) \
			$* \
			.


template-%: | ensure-creds-file-exists-% deps-%
	cd ./$* && \
		helm template \
		--name=$* \
		--values=./.values.yaml \
		$(HELM_FLAGS) \
		.


deploy-%: | ensure-creds-file-exists-% deps-%
	cd ./$* && \
		helm upgrade \
			--tls \
			--install \
			--namespace=$* \
			--timeout=900 \
			--values=./.values.yaml \
			--wait \
			$(HELM_FLAGS) \
			$* \
			.


deps-%:
	cd ./$* && \
		grep 'file://' requirements.yaml || \
		helm dependency update .


ensure-creds-file-exists-%:
	@test -f ./$*/.values.yaml || \
		{ \
			echo "ERROR: $* misses credentials"; \
			echo "Make sure 'deployments/$*/.values.yaml' exists"; \
			exit 1; \
		}
