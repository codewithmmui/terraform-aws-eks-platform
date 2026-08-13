#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
require terraform
env="${1:-dev}"; dir="$(environment_dir "$env")"
[[ -f "$dir/tfplan" ]] || { echo "ERROR: run plan first; tfplan is missing" >&2; exit 1; }
terraform -chdir="$dir" apply tfplan
