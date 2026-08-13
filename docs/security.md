# Security

Controls are layered: private nodes and restricted API endpoints; no SSH; least-privilege IAM and exact IRSA subjects; encrypted state/EBS/ECR; EKS audit logs; immutable/scanned images; non-root, read-only, capability-dropped containers; resource bounds; default-deny policies; and CI scanning with TFLint, Trivy, and Checkov. Secrets Manager plus External Secrets avoids secrets in Git or tfvars. Terraform outputs never expose secret values.

The state bucket blocks public access, denies plaintext transport, encrypts, versions, and uses native S3 lockfiles. Scope state IAM to the environment key. Consider customer-managed KMS keys and access logging in regulated environments. Intentional public exposure is the sample HTTP ALB on ports 80/443; production should use ACM TLS, redirect HTTP, restrict ingress where possible, and add WAF.

Protect `main`: require PRs, CODEOWNERS, successful validation/security/plan checks, conversation resolution, signed commits where appropriate, no force pushes, and no direct pushes. Protect the production GitHub Environment with independent reviewers. Pin Actions to immutable SHAs in a hardened enterprise fork and use artifact attestations/SBOMs.
