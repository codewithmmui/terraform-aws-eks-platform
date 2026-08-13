#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
require aws; require terraform; require kubectl; require curl
env="${1:-dev}"; cluster="$(tf_output "$env" cluster_name)"
aws sts get-caller-identity >/dev/null
aws eks describe-cluster --name "$cluster" --region "${AWS_REGION:-us-east-1}" --query 'cluster.status' --output text | grep -qx ACTIVE
kubectl cluster-info >/dev/null
[[ "$(kubectl get nodes --no-headers | wc -l | tr -d ' ')" -gt 0 ]]; kubectl wait --for=condition=Ready nodes --all --timeout=5m
for workload in deployment/coredns daemonset/kube-proxy daemonset/aws-node; do kubectl rollout status "$workload" -n kube-system --timeout=5m; done
kubectl rollout status deployment/ebs-csi-controller -n kube-system --timeout=5m
kubectl rollout status daemonset/ebs-csi-node -n kube-system --timeout=5m
for ns in argocd monitoring external-secrets ingress-system applications; do kubectl get namespace "$ns" >/dev/null; done
for item in "argocd deployment/argocd-server" "external-secrets deployment/external-secrets" "ingress-system deployment/aws-load-balancer-controller" "applications deployment/test-app"; do set -- $item; kubectl rollout status "$2" -n "$1" --timeout=5m; done
kubectl get ingress -n applications test-app >/dev/null
host="$(kubectl get ingress test-app -n applications -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
if [[ -n "$host" ]]; then curl --fail --retry 5 --retry-delay 10 --max-time 10 "http://$host/" >/dev/null; else echo "WARN: ingress exists but endpoint is not allocated yet"; fi
kubectl top nodes; kubectl top pods -A
echo "All mandatory cluster verification checks passed."
