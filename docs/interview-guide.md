# Interview guide

**Why EKS?** Managed, regional Kubernetes control plane integrated with AWS networking, IAM, load balancing, and support; the trade-off is cost and AWS-specific operational knowledge.

**Why Terraform and remote state?** Declarative reviewable infrastructure, reusable modules, plans, and drift detection. Remote encrypted/versioned state enables team coordination; S3 native lockfiles serialize writers.

**Why private nodes, multiple AZs, and NAT?** Private nodes remove direct internet ingress. AZ spread tolerates a zonal failure when workloads and dependencies are also spread. NAT provides outbound access without public node IPs; per-AZ NAT improves availability, while one NAT costs less.

**How do pods get IPs; what is VPC CNI?** The AWS CNI attaches ENIs and assigns VPC addresses to pods, making them first-class VPC endpoints. Subnet and ENI limits therefore affect scheduling.

**Pod Identity versus IRSA?** Both provide pod-scoped temporary credentials. IRSA uses the cluster OIDC issuer and service-account trust; EKS Pod Identity uses an AWS agent and associations, simplifying trust in many fleets. This project uses IRSA because the supported controller charts expose it consistently; static keys are never used.

**Why GitHub OIDC?** It exchanges a bounded workflow identity for short-lived STS credentials, removing stored AWS keys. Trust is constrained by repository, ref/environment, audience, IAM permissions, and GitHub approval.

**How does EKS authentication work?** IAM authenticates a signed token; EKS access entries map principals to access policies. Kubernetes authorization then applies the associated scope. New access uses the API instead of relying solely on `aws-auth`.

**Why Argo CD?** It continuously reconciles declared Git state, exposes drift, supports rollback and promotion patterns, and separates app delivery from infrastructure credentials. Production may disable automated sync or use promotion PRs/windows.

**Node will not join?** Check node-group health and bootstrap, node IAM, API endpoint reachability, routes/NAT/endpoints, security groups, DNS, AMI/Kubernetes compatibility, and CNI logs in that order.

**CoreDNS is pending?** Check Ready capacity, system taints/tolerations, resource pressure, CNI address allocation, and deployment events. If running but resolution fails, inspect service/endpoints, kube-proxy, NetworkPolicy DNS egress, and upstream VPC DNS.

**What if an AZ fails?** The EKS control plane remains regional. Nodes/NAT in the failed AZ disappear; replicas in other AZs continue only if scheduling, PDBs, topology, storage, and dependencies permit it. Single-AZ EBS volumes require restoration or rescheduling with replicated application data.

**Reduce cost?** One NAT in dev, small/Graviton or diversified Spot nodes, lower non-prod minimums, shorter log retention, optional monitoring, VPC endpoint economics, rightsizing, and timely teardown. EKS itself remains a fixed charge.

**Secure production?** Private API, controlled network path, least privilege/access entries, scoped workload identity, KMS, immutable signed images, admission policy, NetworkPolicy, audit/CloudTrail, secret rotation, protected CI environments, backups, and incident exercises.

**Multi-region?** Independent regional VPC/EKS/state, global DNS or accelerator, replicated ECR/secrets/data, explicit write topology, tested failover/failback, and service-specific RTO/RPO. Kubernetes recreation is simpler than consistent data recovery.
