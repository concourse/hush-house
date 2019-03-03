#!/bin/bash

# Creates the `ssd` StorageClass to be consumed by pods in
# the cluster that need a faster storage device than the
# pd-standard ones that are not SSD based.

set -o errexit
set -o nounset

kubectl apply -f - <<YAML
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ssd
provisioner: kubernetes.io/gce-pd
parameters:
  type: pd-ssd
YAML

