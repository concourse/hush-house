HELM_FLAGS   ?=

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



# TODO deps w/ local file?
#
deps-%:
	echo "hehe deps"
	# cd ./$* && \
	# 	helm dependency update .


ensure-creds-file-exists-%:
	@test -f ./$*/.values.yaml || \
		{ \
			echo "ERROR: $* misses credentials"; \
			echo "Make sure 'deployments/$*/.values.yaml' exists"; \
			exit 1; \
		}
