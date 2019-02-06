#!/bin/bash

# Bootstraps the necessary HELM secrets in the
# k8s cluster under the `hush-house-main` namespace
# where the `hush-house` deployment can fetch secrets
# from.
#
# This is needed so that the `deploy` pipeline[1] can
# make use of Helm with `--tls`.
#
# [1]: https://hush-house.concourse-ci.org/teams/main/pipelines/deploy
#

set -o errexit
set -o nounset
set -o pipefail


kubectl create secret generic helm-ca-cert-b64 \
	--namespace=hush-house-main \
	--from-literal="value=$(cat ./ca.cert.pem | base64)"

kubectl create secret generic helm-cert-b64 \
	--namespace=hush-house-main \
	--from-literal="value=$(cat ./helm.cert.pem | base64)"

kubectl create secret generic helm-key-b64 \
	--namespace=hush-house-main \
	--from-literal="value=$(cat ./helm.key.pem | base64)"

service_account_secret=$(kubectl get serviceaccount tiller \
	--namespace kube-system \
	-o jsonpath='{.secrets[0].name}')
token=$(kubectl get secret $service_account_secret \
	--namespace kube-system \
	-o jsonpath='{.data.token}' | base64 -D)

kubectl config set-credentials ci \
	--token "$token"
