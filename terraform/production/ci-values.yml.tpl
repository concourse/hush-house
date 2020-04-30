image: concourse/concourse-rc
imageTag: 6.0.0

web:
  nodeSelector:
    cloud.google.com/gke-nodepool: generic-1

  resources:
    requests:
      cpu: 1500m
      memory: 1Gi
    limits:
      cpu: 1500m
      memory: 1Gi

  service:
    type: LoadBalancer
    loadBalancerIP: ${lb_address}
