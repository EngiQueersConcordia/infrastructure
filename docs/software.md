# Software

The following software should be kept up to date:

## Talos Linux
See https://docs.siderolabs.com/talos/latest/configure-your-talos-cluster/lifecycle-management/upgrading-talos for 
instructions. You should upgrade to the latest patch release before upgrading to the next major release. Update the
value in script/.config
## Kubernetes
Kubernetes is updated independantly of Talos. See https://docs.siderolabs.com/kubernetes-guides/advanced-guides/upgrading-kubernetes
for instructions. Update the value in script/.config
## Cilium
Cilium is updated through helm. Check https://docs.cilium.io/en/stable/operations/upgrade/ Only upgrade one
minor version at a time. Cilium preflight checks MUST be manually run before upgrading.
## ArgoCD
ArgoCD is updated through helm. Check https://argo-cd.readthedocs.io/en/stable/operator-manual/upgrading/overview/
## Authentik
Authentik is updated through helm. Check https://docs.goauthentik.io/releases/
## Cert Manager
Cert-Manager is updated through helm. Check https://cert-manager.io/docs/releases/
## Cert Manager Webhook OVH
Cert-Manager-Webhook is updated through helm. Check https://github.com/aureq/cert-manager-webhook-ovh/releases
## Descheduler
Descheduler is updated through helm. Check https://github.com/kubernetes-sigs/descheduler/releases
## Harbor
Harbor is updated through helm. Check https://github.com/goharbor/harbor/releases
## Headlamp
Headlamp is updated through helm. Check https://github.com/kubernetes-sigs/headlamp/releases
## Ingress MC
Ingress MC is updated through helm. Check https://github.com/itzg/mc-router/releases
## Kubevirt
Kubevirt is updated through helm. Check https://kubevirt.io/user-guide/cluster_admin/updating_and_deletion/
## OpenEBS
OpenEBS is updated through helm. Check https://openebs.io/docs/user-guides/upgrade
## Postgres
Postgres is updated through helm. Check https://cloudnative-pg.io/documentation/1.16/installation_upgrade/#upgrades
## Sealed Secrets
Sealed Secrets is updated through helm. Check https://github.com/bitnami-labs/sealed-secrets#upgrade