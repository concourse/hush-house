#!/bin/bash

# Installs the local static provisioner that allows us to have
# the automatic creation of PersistentVolumes in our cluster
# so that we can consume local storage (local SSDs on GKE)
# through PersistentVolumeClaims without needing to create the
# PVs ourselves.

set -o errexit
set -o nounset
set -o xtrace

helm upgrade \
	--install \
	--tls \
	--values=./local-provisioner-values.yaml \
	local-static-provisioner \
	./sig-storage-local-static-provisioner/helm/provisioner
