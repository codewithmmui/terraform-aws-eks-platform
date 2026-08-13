#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
require aws; require terraform
env="${1:-dev}"; dir="$(environment_dir "$env")"; vars="${TFVARS_FILE:-terraform.tfvars}"
[[ -f "$dir/backend.hcl" ]] || { echo "Copy backend.hcl.example to backend.hcl and set the state bucket"; exit 1; }
[[ -f "$dir/$vars" ]] || { echo "Copy terraform.tfvars.example to terraform.tfvars and customize it"; exit 1; }
aws sts get-caller-identity >/dev/null
terraform -chdir="$dir" init -backend-config=backend.hcl
terraform -chdir="$dir" plan -var-file="$vars" -out=tfplan
