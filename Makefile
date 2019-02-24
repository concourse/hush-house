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


# Retrieves the credentials necessary for running terraform
# commands under the `./terraform` directory.
gcp-key:
	lpass show hush-house-gcp-key --note > \
		./terraform/gcp.json


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



ci/deploy.json: ci/deployments-with-creds.json ci/deployments-without-creds.json
	jsonnet \
		--ext-code 'deployments-with-creds=$(shell cat ci/deployments-with-creds.json)' \
		--ext-code 'deployments-without-creds=$(shell cat ci/deployments-without-creds.json)' \
		./ci/deploy.jsonnet > $@
.PHONY: ci/deployments.json


ci/deployments-without-creds.json:
	find ./deployments/without-creds -type d -mindepth 1 -maxdepth 1  | \
		cut -d '/' -f4  | \
		jq -RscM '. / "\n" - [""]' | \
		jq '[{"name":.[], "withCreds": false}]' > $@
.PHONY: ci/deployments-without-creds.json

ci/deployments-with-creds.json:
	find ./deployments/with-creds -type d -mindepth 1 -maxdepth 1  | \
		cut -d '/' -f4  | \
		jq -RscM '. / "\n" - [""]' | \
		jq '[{"name":.[], "withCreds": true}]' > $@
.PHONY: ci/deployments-with-creds.json

