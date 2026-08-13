# Disaster recovery

Git plus remote Terraform state reconstructs stateless infrastructure. S3 versioning protects prior state objects; enable cross-region replication and Object Lock where policy requires it. Test restoration, restrict version deletion, and back up Git independently. A deleted local `.terraform` directory is harmless: run `terraform init -reconfigure`.

For corrupt state, stop writers, retain the bad object, restore a known S3 version, run `terraform state list`, `terraform state show`, and `terraform plan`. Import an existing untracked resource with `terraform import`; move renamed addresses with `terraform state mv`. After manual drift or partial apply, inspect AWS and state, rerun plan, and repair incrementally. Never hand-edit state unless vendor support directs it; never use force-unlock without proving the writer is dead.

Recreate EKS from Terraform, configure kubeconfig, reinstall controllers, and let Argo CD restore stateless workloads. ECR recovery requires replication/backup or rebuilding immutable images. Secrets require Secrets Manager replication/backup. Stateful recovery requires application-consistent EBS snapshots or Velero plus database-native backups; Terraform cannot recover data. DNS recovery requires Route 53 records/zones and controlled TTLs.

Example targets: platform RTO 4 hours/RPO 24 hours; critical stateful services require service-specific, usually tighter targets. Multi-region needs replicated data, images, secrets, DNS failover, independent state, and regular exercises—not just a second empty cluster.
