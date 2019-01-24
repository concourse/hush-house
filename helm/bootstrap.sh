#!/bin/bash

# Prepares the k8s cluster to host a Tiller components
# that should be communicated with only through TLS
# connections.

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



# TODO - probably move this to the root Makefile to something
# 	 like `make helm-creds`?
cp ca.cert.pem $(helm home)/ca.pem
cp helm.cert.pem $(helm home)/cert.pem
cp helm.key.pem $(helm home)/key.pem


# TODO - lol, this should not be here
# 	 > should be moved to something like a
# 	 > terraform provisioner that would be
# 	 > trigger right after creating the cluster.
kubectl apply -f - <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ssd
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
YAML

