# EKS

The module creates a regional EKS control plane, private/public endpoint controls, CloudWatch control-plane logs, OIDC provider, EKS access API, dynamic default-version add-ons, and encrypted-secret support when a KMS key is supplied. `API_AND_CONFIG_MAP` permits a deliberate migration from legacy `aws-auth`; new principals should use access entries. Restrict public endpoint CIDRs or disable it and reach the private endpoint through VPN, Direct Connect, or a controlled runner.

CoreDNS, kube-proxy, VPC CNI, and EBS CSI are managed add-ons. Omitting versions asks EKS for its compatible default instead of pinning an obsolete release; production change control may pin tested versions after querying `aws eks describe-addon-versions`. Logs include API, audit, authenticator, controller manager, and scheduler as configured. Retention controls CloudWatch storage cost.

Managed node groups use current EKS-optimized AMIs by leaving AMI selection to EKS. There is no SSH key or inbound administrative port. SSM is available through the scoped managed policy. System On-Demand nodes isolate critical components; application nodes scale conservatively; Spot is appropriate only for interruptible workloads.
