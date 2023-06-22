#!/bin/bash

# Addons
helm uninstall -n kube-system csi-secrets-store
helm uninstall -n kube-system secrets-provider-aws
helm uninstall -n prometheus prometheus
helm uninstall -n grafana grafana
helm uninstall -n kubecost kubecost
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# k8s resources
kubectl apply -f storage_class.yaml
kubectl apply -f credentials.yaml
kubectl kustomize . | kubectl delete -f - 
envsubst < ingress.yaml | kubectl delete -f -
envsubst < addon.yaml | kubectl delete -f -