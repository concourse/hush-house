To update meeting link in `configmap`:

```
kubectl delete configmap nginx-conf -n hangar
kubectl apply -f configmap.yml -n hangar
```
Could be used to update other k8s resource by change the resource name `configmap`
and file name `configmap.yml`


Make sure to restart the deployment
```
kubectl rollout restart deployment hangar-deployment -n hangar
```
