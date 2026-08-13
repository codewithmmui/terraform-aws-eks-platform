#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
require terraform; require kubectl; require helm
env="${1:-dev}"; [[ "$env" != "prod" ]] || [[ "${CONFIRM_PRODUCTION_DESTROY:-}" == "DESTROY-PROD" ]] || { echo "Refusing production destroy"; exit 1; }
dir="$(environment_dir "$env")"
kubectl delete -k "$ROOT_DIR/kubernetes/test-app" --ignore-not-found --timeout=5m || true
for release in monitoring:monitoring external-secrets:external-secrets argocd:argocd ingress-system:aws-load-balancer-controller; do ns="${release%%:*}"; name="${release##*:}"; helm uninstall "$name" -n "$ns" --wait 2>/dev/null || true; done
echo "Waiting for Kubernetes-created load balancers to disappear..."
for _ in {1..30}; do [[ -z "$(kubectl get ingress -A -o name 2>/dev/null)" ]] && break; sleep 10; done
terraform -chdir="$dir" init -backend-config=backend.hcl
terraform -chdir="$dir" plan -destroy -var-file=terraform.tfvars -out=destroy.tfplan
terraform -chdir="$dir" apply destroy.tfplan
