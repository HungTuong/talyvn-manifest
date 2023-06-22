# app-manifest
Run the manifest of the EKS cluster with following command:
```shell
source ./run.sh
```

Delete the manifest of the EKS cluster with following command:
```shell
source ./remove.sh
```

To re-apply file ingress.yaml with following command:
```shell
envsubst < ingress.yaml | kubectl apply -f -
```

# Kubecost
To forward port, using the command:
```shell
# Kubecost PORT FORWARDING
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090:9090
```

# Prometheus
```shell
# Prometheus PORT FORWARDING
export POD_NAME=$(kubectl get pods --namespace prometheus -l "app.kubernetes.io/component=server" -o jsonpath="{.items[0].metadata.name}")
kubectl --namespace prometheus port-forward $POD_NAME 9090:9090
```

# ARGO CD
Get admin password:

```shell
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

# Grafana
Get admin password:
```shell
kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 -d
```
