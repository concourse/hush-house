pipeline: ci/deploy.json

ci/deploy.json: ci/deployments.json
	jsonnet \
		--ext-code 'deployments=$(shell cat ci/deployments.json)' \
		./ci/deploy.jsonnet > $@


ci/deployments.json:
	find ./deployments -type d -mindepth 1 -maxdepth 1 | \
		cut -d '/' -f3  | \
		jq -RscM '. / "\n" - [""]' > $@
.PHONY: ci/deployments.json
