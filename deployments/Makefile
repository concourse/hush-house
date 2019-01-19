HELM_FLAGS   ?=


creds-%:
	cd ./$* && \
		lpass show hush-house-values-$* > ./.values.yaml


template-%:
	cd ./$* && \
		helm template \
		--name=$* \
		--values=./.values.yaml \
		$(HELM_FLAGS) \
		.


deps-%:
	cd ./$* && \
		helm dependency update .


upgrade-%: helm-deps-%
	cd ./$* && \
		helm upgrade \
			--install \
			--namespace=$* \
			--timeout=600 \
			--values=./.values.yaml \
			--wait \
			$(HELM_FLAGS) \
			$* \
			.
