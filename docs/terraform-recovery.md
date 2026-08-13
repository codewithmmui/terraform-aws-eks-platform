# Terraform recovery

- Deleted `.terraform`: rerun `terraform init -reconfigure -backend-config=backend.hcl`.
- Corrupt state: stop writers, preserve evidence, restore a prior S3 object version, then plan.
- Existing but absent: add configuration and use `terraform import ADDRESS ID` or an import block.
- Manual change: inspect with `terraform state show ADDRESS` and `terraform plan`; either revert drift or codify it.
- Partial apply: inspect AWS and `terraform state list`, fix the root error, and rerun a reviewed plan.
- Refactor: use `moved` blocks or `terraform state mv OLD NEW`, not destroy/recreate by accident.

State is sensitive and authoritative. Back it up, serialize writers, never commit it, and avoid manual JSON editing.
