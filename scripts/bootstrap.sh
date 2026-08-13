#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
require aws; require terraform
aws sts get-caller-identity >/dev/null
terraform -chdir="$ROOT_DIR/terraform/bootstrap/remote-state" init
terraform -chdir="$ROOT_DIR/terraform/bootstrap/remote-state" plan -out=bootstrap.tfplan
echo "Review the plan, then run: terraform -chdir=terraform/bootstrap/remote-state apply bootstrap.tfplan"
