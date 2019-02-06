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

kubectl patch deploy \
	tiller-deploy \
	--namespace kube-system \
	-p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

helm init \
	--service-account tiller \
	--tiller-tls \
	--tiller-tls-cert ./tiller.cert.pem \
	--tiller-tls-key ./tiller.key.pem \
	--tls-ca-cert ca.cert.pem \
	--tiller-tls-verify \
	--upgrade

# TODO - move this to a Terraform provisioner or something similar
kubectl apply -f - <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ssd
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
YAML

