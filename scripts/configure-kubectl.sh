#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
require aws; require terraform; require kubectl
env="${1:-dev}"; cluster="$(tf_output "$env" cluster_name)"
region="${AWS_REGION:-$(aws configure get region 2>/dev/null || true)}"; region="${region:-us-east-1}"
aws eks update-kubeconfig --name "$cluster" --region "$region"
kubectl cluster-info
