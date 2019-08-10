# registry

A toy container registry to be used from within the cluster to play around with a more permissive registry than DockerHub.


## Usage

Reference the registry by using its full name:

- registry-docker-registry.registry.svc.cluster.local:5000


For instance, in your pipeline:

```yaml
resources:
- type: registry-image
  name: image
  source:
    repository: registry-docker-registry.registry.svc.cluster.local:5000/imagename
```

