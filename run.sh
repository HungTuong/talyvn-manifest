#!/bin/bash

# secrets addon
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm repo add aws-secrets-manager https://aws.github.io/secrets-store-csi-driver-provider-aws

helm uninstall -n kube-system csi-secrets-store
helm uninstall -n kube-system secrets-provider-aws


helm install -n kube-system csi-secrets-store \
--set syncSecret.enabled=true \
--set enableSecretRotation=true \
secrets-store-csi-driver/secrets-store-csi-driver

helm install -n kube-system secrets-provider-aws aws-secrets-manager/secrets-store-csi-driver-provider-aws


kubectl get daemonsets -n kube-system -l app=csi-secrets-store-provider-aws
kubectl get daemonsets -n kube-system -l app.kubernetes.io/instance=csi-secrets-store

kubectl apply -f credentials.yaml

# monitoring with prometheus and grafana
kubectl create namespace prometheus

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm uninstall -n prometheus prometheus
kubectl apply -f storage_class.yaml
helm upgrade --install prometheus prometheus-community/prometheus \
    --namespace prometheus \
    --set server.retention="1h" \
    --set server.persistentVolume.storageClass="gp3" \
    --set alertmanager.enabled="false" \
    --set-file additionalScrapeConfigs=extraScrapeConfigs.yaml

kubectl create ns grafana

helm repo add grafana https://grafana.github.io/helm-charts

helm uninstall -n grafana grafana
helm upgrade --install grafana grafana/grafana \
    --namespace grafana \
    --set persistence.storageClassName=gp3 \
    --set persistence.enabled=true \
    --values grafana.yaml


# Kubecost
helm upgrade --install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace \
  --set global.prometheus.fqdn=http://prometheus-server.prometheus.svc.cluster.local \
  --set global.prometheus.enabled=false \
  --set persistentVolume.storageClass=gp3

# ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Store the AWS WAF web ACL’s Id in an environment variable
export WAF_ARN=$(aws wafv2 list-web-acls \
  --scope REGIONAL \
  --query "WebACLs[?starts_with(Name, 'thesis')].ARN" \
  --output text)

# Run the workload
# kubectl apply -f backend_deployment.yaml
kubectl kustomize . | kubectl apply -f - 
envsubst < ingress.yaml | kubectl apply -f -
envsubst < addon.yaml | kubectl apply -f -

# Add repo in argocd
source ./argocd/argo-run.sh