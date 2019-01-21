HELM_FLAGS   ?=


creds-%:
	cd ./$* && \
		lpass show hush-house-values-$* > ./.values.yaml


save-creds-%:
	cd ./$* && \
		cat ./.values.yaml | \
			lpass edit \
				--sync=now \
				--non-interactive \
				hush-house-values-$*


template-%:
	cd ./$* && \
		helm template \
		--name=$* \
		--values=./.values.yaml \
		$(HELM_FLAGS) \
		.


diff-%:
	cd ./$* && \
		helm diff upgrade \
			--tls \
			--namespace=$* \
			--detailed-exitcode \
			--values=./.values.yml \
			$(HELM_FLAGS) \
			$* \
			.


upgrade-%: deps-%
	cd ./$* && \
		helm upgrade \
			--tls \
			--install \
			--namespace=$* \
			--timeout=600 \
			--values=./.values.yaml \
			--wait \
			$(HELM_FLAGS) \
			$* \
			.


deps-%:
	cd ./$* && \
		helm dependency update .


