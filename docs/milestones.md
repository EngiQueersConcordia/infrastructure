# Milestones
Milestones represent levels of server functionalities.
User projects are not listed here. Only system functionalities.

## Milestone 1: Core Cluster
At this level, basic workloads may be run and accessed by authorized users only.

- Talos Linux (OS)
- Kubernetes (Management Layer)
- Cilium (Networking)

## Milestone 2: Internet Services
At this level, basic web services may be run.

- Envoy (Web Server)
- Cert Manager (TLS Certificate Automation)
- GoAuthentik (Authentication System)
- ArgoCD (Code Deployment System)
- K8s OIDC Login (Management Layer Authentication)
- Network Policy + Host Policy (Firewall)

## Milestone 3: Storage
At this level, all services may be run.

- OpenEBS (Storage Provider)
- KubeVirt (Virtual Machines)

## Milestone 4: Monitoring
At this level, internal systems monitor the health of the server nodes and report anomalous situations.

- Prometheus (Metric Server)
- Exporters (Metric Clients)
- Alertmanager (Alerting & Notification System)
- Grafana (Metric Visualisation Service)

## Milestone 5 Backups
At this level, the system makes automatic backups of important components.

- OpenEBS Snapshots (Daily Incremental Backups)
- Etcd Snapshots (Management Layer Backups)

## Future (Potential) Plans

- NeuVector (Runtime Security Scans)
- Harbor (Container Registry)
- TBA/Unknown (CI/CD Runner)

