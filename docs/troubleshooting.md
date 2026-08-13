# Troubleshooting

Start with identity, state, events, and controller logs; do not retry destructive operations blindly.

## Terraform

- Backend init: verify bucket/region, `s3:GetObject/PutObject/ListBucket`, native lockfile permissions, and `terraform init -reconfigure -backend-config=backend.hcl`.
- Lock: identify the active run. Only after proving it is dead use `terraform force-unlock LOCK_ID`.
- Authentication/denied: run `aws sts get-caller-identity`, inspect CloudTrail and the exact denied action/resource, and correct scoped policy.
- Existing resource: decide ownership, then use an `import` block or `terraform import ADDRESS ID`; never simply rename it.
- Drift/partial apply: `terraform state list`, `terraform state show ADDRESS`, refresh with `terraform plan`, repair the cause, and apply the reviewed delta.

## EKS

- Nodes not joining: inspect node-group health, routes/NAT/endpoints, security groups, DHCP/DNS, node IAM, AMI compatibility, and `aws eks describe-nodegroup`.
- Unauthorized kubectl: confirm caller identity, kubeconfig context, access entry/policy, and token with `aws eks get-token`.
- CoreDNS pending: check node capacity, taints/tolerations, CNI IP availability, and `kubectl -n kube-system describe deploy coredns`.
- CNI/IP failure: inspect `aws-node` logs, subnet free IPs, EC2 API access, CNI IAM, and prefix-delegation settings.

## Load balancer and storage

For a missing ALB, inspect Ingress events, controller logs, subnet tags, annotations, IRSA, quotas, and security groups. For unhealthy targets, verify readiness, target port, NetworkPolicy, health path, and pod security-group routing. For pending PVCs, inspect the claim/events, StorageClass, EBS CSI deployments/node DaemonSet, IRSA, AZ scheduling, and EC2 volume quotas.

## GitHub Actions

OIDC failures usually mean a trust-policy `sub`/`aud` mismatch, wrong role/provider, missing `id-token: write`, or Environment selection. Approval issues require an authorized reviewer and matching protected Environment. Backend and tfvars are intentionally ignored; supply backend flags and `TF_VAR_*` through environment configuration.

## Command toolbox

```bash
kubectl get nodes
kubectl get pods -A
kubectl get events -A --sort-by=.metadata.creationTimestamp
kubectl describe node <node>
kubectl describe pod <pod> -n <namespace>
kubectl logs <pod> -n <namespace>
kubectl get svc -A
kubectl get ingress -A
kubectl get storageclass
kubectl get pvc -A
kubectl top nodes
kubectl top pods -A
aws sts get-caller-identity
aws eks list-clusters
aws eks describe-cluster --name <cluster>
aws eks update-kubeconfig --name <cluster> --region <region>
aws ecr describe-repositories
```
