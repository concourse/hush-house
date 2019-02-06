HELM_HOME ?= $(shell helm home)

# Generates the `deploy` pipeline [1] based on the
# `jsonnet` file under `ci`.
#
# [1]: https://hush-house.concourse-ci.org/teams/main/pipelines/deploy
#
deploy-pipeline: ci/deploy.json


# Retrieves the credentials necessary for running commands
# against the `hush-house` cluster using mutual tls
helm-creds: helm-creds-tls-ca helm-creds-tls-helm helm-creds-tls-tiller


# Copies the Helm TLS credentials obtained by `helm-creds`
# into helm's home directory so that `--tls` makes use of
# those when connecting.
helm-set-client-creds:
	cp ./helm/ca.cert.pem $(HELM_HOME)/ca.pem
	cp ./helm/helm.cert.pem $(HELM_HOME)/cert.pem
	cp ./helm/helm.key.pem $(HELM_HOME)/key.pem


helm-creds-tls-%:
	lpass show hush-house-helm-tls-$* \
		--field=certificate-b64 | \
		base64 --decode > ./helm/$*.cert.pem
	lpass show hush-house-helm-tls-$* \
		--field=key-b64 | \
		base64 --decode > ./helm/$*.key.pem



ci/deploy.json: ci/deployments.json
	jsonnet \
		--ext-code 'deployments=$(shell cat ci/deployments.json)' \
		./ci/deploy.jsonnet > $@


ci/deployments.json:
	find ./deployments -type d -mindepth 1 -maxdepth 1 | \
		cut -d '/' -f3  | \
		jq -RscM '. / "\n" - [""]' > $@
.PHONY: ci/deployments.json
