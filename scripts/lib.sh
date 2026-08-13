#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
require() { command -v "$1" >/dev/null 2>&1 || { echo "ERROR: required command '$1' is not installed" >&2; exit 1; }; }
environment_dir() { local env="${1:-}"; [[ "$env" =~ ^(dev|staging|prod)$ ]] || { echo "ERROR: ENV must be dev, staging, or prod" >&2; exit 1; }; printf '%s/terraform/environments/%s' "$ROOT_DIR" "$env"; }
tf_output() { terraform -chdir="$(environment_dir "$1")" output -raw "$2"; }
