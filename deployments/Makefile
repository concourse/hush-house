HELM_FLAGS   ?=


creds-%:
	cd ./$* && \
		lpass show hush-house-values-$* > ./.values.yml


helm-deps-%:
	helm dependency update .


upgrade-%: helm-deps-%
	cd ./$* && \
		helm upgrade \
			--install \
			--namespace=$* \
			--values=./.values.yml \
			--timeout=600 \
			--wait \
			$(HELM_FLAGS) \
			$* \
			.
