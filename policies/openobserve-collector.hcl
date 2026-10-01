# openobserve-collector's namespace, through Vault Secrets Operator (its
# Kubernetes auth role): its own secrets, and the shared ones it uses, each by
# name.

path "platform/data/openobserve-collector/*" {
  capabilities = ["read"]
}

# OpenObserve's root user: the collectors send with it.
path "platform/data/shared/openobserve-root" {
  capabilities = ["read"]
}
