# Observability

The optional kube-prometheus-stack supplies Prometheus, Alertmanager, Grafana, kube-state-metrics, node exporter, and standard dashboards covering cluster health, nodes, pod CPU/memory/restarts, and deployment replicas. `platform-alerts.yaml` adds sustained alerts for NotReady nodes, restarts, unavailable replicas, high CPU/memory, and filling volumes. Route Alertmanager notifications through organization-owned receivers and test them.

Metrics Server supplies the resource metrics API for `kubectl top` and HPA; it is not long-term monitoring. If metrics are absent, inspect `kubectl get apiservice v1beta1.metrics.k8s.io`, Metrics Server logs, kubelet reachability/certificates, and resource requests.

Recommended optional logging is pod stdout/stderr → Fluent Bit or Grafana Alloy DaemonSet → Loki (or CloudWatch/OpenSearch) → Grafana. Add retention, tenant isolation, PII redaction, encryption, and ingestion budgets before enabling it. Monitoring is opt-in in dev because its replicas and storage cost money.
