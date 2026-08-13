# IAM

The cluster role carries only AmazonEKSClusterPolicy. Nodes carry worker, ECR read, CNI, and SSM managed policies—not AdministratorAccess. Controller roles trust exact Kubernetes service-account subjects through the cluster OIDC provider. EBS CSI, ALB Controller, External Secrets, and optional ExternalDNS therefore receive credentials through IRSA, with no static keys and no permission inherited by every pod.

GitHub exchanges its signed OIDC token for short-lived STS credentials. Trust must be restricted to the repository, branch/environment subjects, and audience `sts.amazonaws.com`. Use separate plan and apply roles: plan needs state access plus describe/list/read; apply needs the explicitly reviewed create/update/delete surface. The module accepts policy ARNs because organization boundaries differ; never attach AdministratorAccess as a shortcut.

EKS human access uses access entries: cluster admin for a break-glass/platform role, namespace-scoped edit for developers, view for read-only users, and only required access for CI. Avoid mapping individual users. Audit role assumptions in CloudTrail and rotate access by changing group/role membership.
