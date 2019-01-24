# Generates the `deploy` pipeline [1] based on the
# `jsonnet` file under `ci`.
#
# [1]: https://hush-house.concourse-ci.org/teams/main/pipelines/deploy
#
deploy-pipeline: ci/deploy.json


ci/deploy.json: ci/deployments.json
	jsonnet \
		--ext-code 'deployments=$(shell cat ci/deployments.json)' \
		./ci/deploy.jsonnet > $@


ci/deployments.json:
	find ./deployments -type d -mindepth 1 -maxdepth 1 | \
		cut -d '/' -f3  | \
		jq -RscM '. / "\n" - [""]' > $@
.PHONY: ci/deployments.json
