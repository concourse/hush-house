#!/bin/bash

# Prepares the k8s cluster to host a Tiller components
# that should be communicated with only through TLS
# connections.
#
# This should only be run once right after the creation
# of the cluster.

set -o errexit
set -o nounset

kubectl create serviceaccount \
	--namespace kube-system \
	tiller

kubectl create clusterrolebinding \
	tiller-cluster-rule \
	--clusterrole=cluster-admin \
	--serviceaccount=kube-system:tiller

helm init \
	--service-account tiller \
	--tiller-tls \
	--tiller-tls-cert ../helm/tiller.cert.pem \
	--tiller-tls-key ../helm/tiller.key.pem \
	--tls-ca-cert ../helm/ca.cert.pem \
	--tiller-tls-verify \
	--upgrade
