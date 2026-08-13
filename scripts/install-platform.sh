#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
require helm; require kubectl; require terraform
env="${1:-dev}"; dir="$(environment_dir "$env")"; cluster="$(tf_output "$env" cluster_name)"; vpc="$(tf_output "$env" vpc_id)"
roles="$(terraform -chdir="$dir" output -json workload_role_arns)"
role() { printf '%s' "$roles" | sed -n "s/.*\"$1\":\"\([^\"]*\)\".*/\1/p"; }
kubectl apply -f "$ROOT_DIR/kubernetes/namespaces/namespaces.yaml"
helm repo add eks https://aws.github.io/eks-charts; helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/; helm repo add argo https://argoproj.github.io/argo-helm; helm repo add external-secrets https://charts.external-secrets.io; helm repo add prometheus-community https://prometheus-community.github.io/helm-charts; helm repo add external-dns https://kubernetes-sigs.github.io/external-dns/; helm repo update
helm upgrade --install aws-load-balancer-controller eks/aws-load-balancer-controller -n ingress-system -f "$ROOT_DIR/helm/aws-load-balancer-controller/values.yaml" --set clusterName="$cluster" --set vpcId="$vpc" --set region="${AWS_REGION:-us-east-1}" --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="$(role alb)" --wait
helm upgrade --install metrics-server metrics-server/metrics-server -n kube-system -f "$ROOT_DIR/helm/metrics-server/values.yaml" --wait
helm upgrade --install argocd argo/argo-cd -n argocd -f "$ROOT_DIR/helm/argocd/values.yaml" --wait
helm upgrade --install external-secrets external-secrets/external-secrets -n external-secrets -f "$ROOT_DIR/helm/external-secrets/values.yaml" --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="$(role eso)" --wait
if [[ "${ENABLE_EXTERNAL_DNS:-false}" == "true" ]]; then helm upgrade --install external-dns external-dns/external-dns -n external-dns -f "$ROOT_DIR/helm/external-dns/values.yaml" --set txtOwnerId="$cluster" --set serviceAccount.annotations."eks\.amazonaws\.com/role-arn"="$(role dns)" --wait; fi
if [[ "${ENABLE_MONITORING:-false}" == "true" ]]; then helm upgrade --install monitoring prometheus-community/kube-prometheus-stack -n monitoring -f "$ROOT_DIR/helm/monitoring/values.yaml" --wait; kubectl apply -f "$ROOT_DIR/kubernetes/platform/monitoring/platform-alerts.yaml"; fi
kubectl apply -f "$ROOT_DIR/kubernetes/platform/storage/storageclass.yaml"
kubectl apply -k "$ROOT_DIR/kubernetes/test-app"
