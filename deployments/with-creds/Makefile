HELM_FLAGS   ?=


hush-house-creds-secrets-%: ensure-creds-file-exists-% deps-%
	kubectl create secret generic $*-values-b64 \
		--namespace=hush-house-main \
		--from-literal="value=$(shell cat ./$*/.values.yaml | base64)" \
		--dry-run \
		--output yaml | kubectl apply -f -


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
			--set=concourse.web.annotations.time=`date +%s` \
			$(HELM_FLAGS) \
			$* \
			.


template-%: | ensure-creds-file-exists-% deps-%
	cd ./$* && \
		helm template \
		--name=$* \
		--values=./.values.yaml \
		--set=concourse.web.annotations.time=`date +%s` \
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
			--set=concourse.web.annotations.time=\"`date +%s`\" \
			--wait \
			$(HELM_FLAGS) \
			$* \
			.


deps-%:
	cd ./$* && \
		helm dependency update .


ensure-creds-file-exists-%:
	@test -f ./$*/.values.yaml || \
		{ \
			echo "ERROR: $* misses credentials"; \
			echo "Make sure 'deployments/$*/.values.yaml' exists"; \
			exit 1; \
		}
