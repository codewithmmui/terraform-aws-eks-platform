# Cost optimization

Material costs are the EKS control plane, EC2 nodes, NAT Gateway hours/data, ALBs, EBS, CloudWatch ingestion/retention, and optional monitoring. Dev selects one NAT, t3 nodes, Spot capacity, seven-day logs, ephemeral Prometheus, and optional controllers. Prod pays for NAT per AZ and baseline On-Demand replicas to remove single-AZ dependencies.

Use AWS Budgets, cost-allocation tags, rightsizing, Graviton-compatible images, Spot diversification, scheduled non-production shutdown/recreation, log sampling/retention, VPC endpoints, and periodic idle ALB/EBS/EIP reviews. A NAT instance can be cheaper but shifts patching and availability onto the team. Always consult current regional pricing; costs change.

Karpenter provisions instances from actual unschedulable pod constraints and consolidates capacity; Cluster Autoscaler changes desired size inside predefined node groups. Karpenter improves flexibility and bin-packing but adds controller/IAM/NodeClass operational surface. Keep a small managed system group and adopt Karpenter only after testing interruption, disruption budgets, and consolidation.
