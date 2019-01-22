#!/bin/bash

set -o errexit
set -o nounset

kubectl create secret generic helm-ca-cert-b64 \
	--namespace=hush-house-main \
	--from-literal="value=$(cat ./ca.cert.pem | base64)"
kubectl create secret generic helm-cert-b64 \
	--namespace=hush-house-main \
	--from-literal="value=$(cat ./helm.cert.pem | base64)"
kubectl create secret generic helm-key-b64 \
	--namespace=hush-house-main \
	--from-literal="value=$(cat ./helm.key.pem | base64)"
