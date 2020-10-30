HELM_FLAGS   ?=
KAPP_FLAGS   ?=

%-ci:
	cd ci && make $*-ci


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
		helm3 diff upgrade \
			--namespace=$* \
			--detailed-exitcode \
			--values=./.values.yaml \
			$(HELM_FLAGS) \
			$* \
			.


template-%: | ensure-creds-file-exists-% deps-%
	cd ./$* && \
		helm3 template \
		--namespace $* \
		--values=./.values.yaml \
		$(HELM_FLAGS) \
		$* \
		. > .template.yaml


deploy-%: | template-%
	cd ./$* && \
		kapp deploy \
			--namespace=$* \
			--app=$* \
			--file=.template.yaml \
			--diff-changes \
			$(KAPP_FLAGS)


deps-%:
	cd ./$* && \
		grep 'file://' requirements.yaml || \
		helm3 dependency update .


ensure-creds-file-exists-%:
	@test -f ./$*/.values.yaml || \
		{ \
			echo "ERROR: $* misses credentials"; \
			echo "Make sure 'deployments/$*/.values.yaml' exists"; \
			exit 1; \
		}
