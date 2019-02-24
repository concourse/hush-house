HELM_FLAGS   ?=


diff-%: deps-%
	cd ./$* && \
		helm diff upgrade \
			--tls \
			--namespace=$* \
			--detailed-exitcode \
			$(HELM_FLAGS) \
			$* \
			.


template-%: deps-%
	cd ./$* && \
		helm template \
		--name=$* \
		$(HELM_FLAGS) \
		.



deploy-%: deps-%
	cd ./$* && \
		helm upgrade \
			--tls \
			--install \
			--namespace=$* \
			--timeout=600 \
			--wait \
			$(HELM_FLAGS) \
			$* \
			.


deps-%:
	cd ./$* && \
		helm dependency update .
