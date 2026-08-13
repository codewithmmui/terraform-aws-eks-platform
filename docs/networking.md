# Networking

Each environment receives a non-overlapping /16. Public /24 subnets route `0.0.0.0/0` to the Internet Gateway and are tagged `kubernetes.io/role/elb=1`. Private /24 subnets route outbound traffic through NAT and are tagged `kubernetes.io/role/internal-elb=1`. Nodes have no public IP and run only in private subnets; this removes direct internet reachability while preserving controlled egress for registries and APIs.

The VPC CNI allocates VPC addresses to pods from node subnet capacity. Size private subnets for nodes plus pods, and monitor address use; prefix delegation or secondary CIDRs may be needed at scale. ALB target type `ip` routes directly to pod IPs. Security groups protect AWS paths; Kubernetes NetworkPolicies protect pod flows only when a supporting network-policy engine is enabled.

A single NAT reduces hourly cost but is an AZ dependency and may incur cross-AZ charges. NAT per AZ keeps private subnet egress local and survives one AZ failure at greater fixed cost. VPC endpoints for ECR, S3, STS, CloudWatch, and Secrets Manager can reduce NAT dependency and tighten egress.
