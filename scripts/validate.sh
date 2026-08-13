#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
require terraform
terraform fmt -check -recursive "$ROOT_DIR/terraform"
for env in dev staging prod; do terraform -chdir="$(environment_dir "$env")" init -backend=false; terraform -chdir="$(environment_dir "$env")" validate; done
terraform -chdir="$ROOT_DIR/terraform/bootstrap/remote-state" init -backend=false
terraform -chdir="$ROOT_DIR/terraform/bootstrap/remote-state" validate
if command -v tflint >/dev/null; then (cd "$ROOT_DIR" && tflint --recursive); else echo "WARN: tflint not installed"; fi
if command -v trivy >/dev/null; then trivy config "$ROOT_DIR"; else echo "WARN: trivy not installed"; fi
if command -v checkov >/dev/null; then checkov -d "$ROOT_DIR"; else echo "WARN: checkov not installed"; fi
